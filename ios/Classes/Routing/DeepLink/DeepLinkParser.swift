// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  DeepLinkParser.swift

import Foundation
import MacaroonUtils
import UIKit

final class DeepLinkParser {
    private let sharedDataController: SharedDataController
    
    init(
        sharedDataController: SharedDataController
    ) {
        self.sharedDataController = sharedDataController
    }
}

extension DeepLinkParser {
    func discover(
        notification: AlgorandNotification
    ) -> Result? {
        let action = resolveNotificationAction(for: notification)

        switch action {
        case .assetOptIn:
            return makeAssetTransactionRequestScreen(for: notification)
        case .assetTransactions:
            return makeAssetTransactionDetailScreen(for: notification)
        default:
            return nil
        }
    }

    func resolveNotificationAction(
        for notification: AlgorandNotification
    ) -> NotificationAction? {
        guard let url = notification.detail?.url else {
            return nil
        }

        return resolveNotificationAction(for: url)
    }

    func discover(
        notification: NotificationMessage
    ) -> Result? {
        let action = resolveNotificationAction(for: notification)

        switch action {
        case .assetOptIn:
            return makeAssetOptInScreen(for: notification)
        case .assetTransactions:
            return makeAssetTransactionDetailScreen(for: notification)
        default:
            return nil
        }
    }

    private func resolveNotificationAction(
        for notificationMessage: NotificationMessage
    ) -> NotificationAction? {
        guard let url = notificationMessage.url else {
            return nil
        }

        return resolveNotificationAction(for: url)
    }

    private func resolveNotificationAction(
        for url: URL?
    ) -> NotificationAction? {
        guard let url = url else {
            return nil
        }

        guard let host = url.host else {
            return nil
        }

        let path = url.path

        let aRawValue = host + path

        return NotificationAction(rawValue: aRawValue)
    }

    private func makeAssetOptInScreen(for notificationMessage: NotificationMessage) -> Result? {
        let url = notificationMessage.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }

        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value

        let isWatchAccount = rawAccount.isWatchAccount()

        if isWatchAccount {
            return .failure(.tryingToOptInForWatchAccount)
        }

        if rawAccount.containsAsset(assetID) {
            let asset = sharedDataController.assetDetailCollection[assetID]!
            return .success(.asaDiscoveryWithOptOutAction(account: rawAccount, asset: asset))
        }

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptInRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptInRequest(accountName: accountName))
        }

        return .success(.asaDiscoveryWithOptInAction(account: rawAccount, assetID: assetID))
    }

    private func makeAssetTransactionDetailScreen(for notificationMessage: NotificationMessage) -> Result? {
        let url = notificationMessage.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }

        let isAlgo = assetID == 0

        if isAlgo {
            return makeTransactionDetailScreen(accountAddress: accountAddress)
        }

        return makeAssetTransactionDetailScreen(
            accountAddress: accountAddress,
            assetID: assetID
        )
    }

    private func makeTransactionDetailScreen(
        for notification: AlgorandNotification
    ) -> Result? {
        let url = notification.detail?.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]

        guard let accountAddress = accountAddress else {
            return nil
        }
        
        return makeTransactionDetailScreen(accountAddress: accountAddress)
    }

    private func makeTransactionDetailScreen(
        accountAddress: PublicKey
    ) -> Result? {
        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value
        return .success(.asaDetail(account: rawAccount, asset: rawAccount.algo))
    }
    
    private func makeAssetTransactionDetailScreen(
        for notification: AlgorandNotification
    ) -> Result? {
        let url = notification.detail?.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }

        let isAlgo = assetID == 0

        if isAlgo {
            return makeTransactionDetailScreen(accountAddress: accountAddress)
        }
        
        return makeAssetTransactionDetailScreen(
            accountAddress: accountAddress,
            assetID: assetID
        )
    }

    private func makeAssetTransactionDetailScreen(
        accountAddress: PublicKey,
        assetID: AssetID
    ) -> Result? {
        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value

        let monitor = sharedDataController.blockchainUpdatesMonitor

        let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptInRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptInRequest(accountName: accountName))
        }

        let hasPendingOptOutRequest = monitor.hasPendingOptOutRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptOutRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptOutRequest(accountName: accountName))
        }

        if let asset = rawAccount[assetID] as? StandardAsset {
            return .success(.asaDetail(account: rawAccount, asset: asset))
        }

        if let collectibleAsset = rawAccount[assetID] as? CollectibleAsset {
            return .success(.collectibleDetail(account: rawAccount, asset: collectibleAsset))
        }

        return .failure(.assetNotFound)
    }

    private func makeAssetTransactionRequestScreen(
        for notification: AlgorandNotification
    ) -> Result? {
        let url = notification.detail?.url
        let params = url?.queryParameters
        let accountAddress = params?["account"]
        let assetID = params?["asset"].unwrap { AssetID($0) }

        guard
            let accountAddress = accountAddress,
            let assetID = assetID
        else {
            return nil
        }
        
        guard sharedDataController.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let account = sharedDataController.accountCollection[accountAddress]

        guard let account = account else {
            return .failure(.accountNotFound)
        }

        guard account.isAvailable else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value

        let isWatchAccount = rawAccount.isWatchAccount()

        if isWatchAccount {
            return .failure(.tryingToOptInForWatchAccount)
        }

        if rawAccount.containsAsset(assetID) {
            let asset = sharedDataController.assetDetailCollection[assetID]!
            return .success(.asaDiscoveryWithOptOutAction(account: rawAccount, asset: asset))
        }

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
            assetID: assetID,
            for: rawAccount
        )
        if hasPendingOptInRequest {
            let accountName = rawAccount.primaryDisplayName
            return .failure(.tryingToActForAssetWithPendingOptInRequest(accountName: accountName))
        }
        
        let accountName = rawAccount.name ?? accountAddress
        let draft = AssetAlertDraft(
            account: rawAccount,
            assetId: assetID,
            asset: nil,
            title: "asset-support-add-title".localized,
            detail: String(format: "asset-support-add-message".localized, "\(accountName)"),
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )
        return .success(.assetActionConfirmation(draft: draft))
    }
}

extension DeepLinkParser {
    func discover(
        qrText: QRText
    ) -> Result? {
        switch qrText.mode {
        case .address:
            return makeActionSelectionScreen(
                qrText
            )
        case .algosRequest:
            return makeTransactionRequestScreen(
                qrText
            )
        case .assetRequest:
            return makeAssetTransactionRequestScreen(
                qrText
            )
        case .optInRequest:
            return makeAssetOptInRequestScreen(
                qrText
            )
        case .mnemonic:
            return nil
        }
    }
    
    private func makeActionSelectionScreen(
        _ qr: QRText
    ) -> Result? {
        let address = qr.address
        return address.unwrap {
            .success(.actionSelection(address: $0, label: qr.label))
        }
    }
    
    private func makeTransactionRequestScreen(
        _ qr: QRText
    ) -> Result? {
        guard let amount = qr.amount else {
            return nil
        }

        guard
            let accountAddress = qr.address,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAssetsToBeAvailable)
        }

        let qrDraft = QRSendTransactionDraft(
            toAccount: accountAddress,
            amount: amount.toAlgos,
            note: qr.note,
            lockedNote: qr.lockedNote,
            transactionMode: .algo
        )

        return .success(.sendTransaction(draft: qrDraft))
    }
    
    private func makeAssetTransactionRequestScreen(
        _ qr: QRText
    ) -> Result? {
        guard let assetId = qr.asset, let amount = qr.amount else {
            return nil
        }

        guard
            let accountAddress = qr.address,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAssetsToBeAvailable)
        }

        let nonWatchAccounts = sharedDataController.accountCollection.filter { !$0.value.isWatchAccount() }

        let hasAsset = nonWatchAccounts.contains { account in
            return account.value.containsAsset(assetId)
        }

        guard
            hasAsset,
            let assetDecoration = sharedDataController.assetDetailCollection[assetId]
        else {
            let draft = AssetAlertDraft(
                account: nil,
                assetId: assetId,
                asset: nil,
                title: "asset-support-your-add-title".localized,
                detail: "asset-support-your-add-message".localized,
                cancelTitle: "title-close".localized
            )
            return .success(
                .assetActionConfirmation(
                    draft: draft,
                    theme: .secondaryActionOnly
                )
            )
        }

        /// <todo> Support the collectibles later when its detail screen is done.

        let qrDraft = QRSendTransactionDraft(
            toAccount: accountAddress,
            amount: amount.assetAmount(fromFraction: assetDecoration.decimals),
            note: qr.note,
            lockedNote: qr.lockedNote,
            transactionMode: .asset(StandardAsset(asset: ALGAsset(id: assetDecoration.id), decoration: assetDecoration))
        )

        let shouldFilterAccount: (Account) -> Bool = {
            !$0.containsAsset(assetId)
        }

        return .success(
            .sendTransaction(
                draft: qrDraft,
                shouldFilterAccount: shouldFilterAccount
            )
        )
    }

    private func makeAssetOptInRequestScreen(
        _ qr: QRText
    ) -> Result? {
        guard let assetID = qr.asset else {
            return nil
        }

        return .success(.accountSelect(asset: assetID))
    }
}

extension DeepLinkParser {
    func discover(
        walletConnectSessionRequest: URL
    ) -> Swift.Result<String, Error>? {
        if !sharedDataController.isAvailable {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        let urlComponents =
            URLComponents(url: walletConnectSessionRequest, resolvingAgainstBaseURL: true)
        let queryItems = urlComponents?.queryItems
        let maybeWalletConnectSessionKey = queryItems?.first(matching: (\.name, "uri"))?.value
        return maybeWalletConnectSessionKey
            .unwrap(where: \.isWalletConnectConnection)
            .unwrap({ .success($0) })
    }
    
    func discover(
        walletConnectRequest draft: WalletConnectRequestDraft
    ) -> Result? {
        if !sharedDataController.isAvailable {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        return .success(.wcMainTransactionScreen(draft: draft))
    }
    
    func discoverBuyAlgo(
        draft: BuyAlgoDraft
    ) -> Result? {
        if !sharedDataController.isAvailable {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        return .success(.buyAlgo(draft: draft))
    }
}

extension DeepLinkParser {
    typealias Result = Swift.Result<Screen, Error>
    
    enum Screen {
        case actionSelection(
            address: String,
            label: String?
        )
        case assetActionConfirmation(
            draft: AssetAlertDraft,
            theme: AssetActionConfirmationViewControllerTheme = .init()
        )
        case asaDiscoveryWithOptInAction(
            account: Account,
            assetID: AssetID
        )
        case asaDiscoveryWithOptOutAction(
            account: Account,
            asset: AssetDecoration
        )
        case asaDetail(
            account: Account,
            asset: Asset
        )
        case collectibleDetail(
            account: Account,
            asset: CollectibleAsset
        )
        case sendTransaction(
            draft: QRSendTransactionDraft,
            shouldFilterAccount: ((Account) -> Bool)? = nil
        )
        case wcMainTransactionScreen(draft: WalletConnectRequestDraft)
        case buyAlgo(draft: BuyAlgoDraft)
        case accountSelect(asset: AssetID)
    }
    
    enum Error:
        Swift.Error,
        Equatable {
        case waitingForAccountsToBeAvailable
        case waitingForAssetsToBeAvailable
        case tryingToOptInForWatchAccount
        case tryingToActForAssetWithPendingOptInRequest(accountName: String)
        case tryingToActForAssetWithPendingOptOutRequest(accountName: String)
        case accountNotFound
        case assetNotFound

        typealias UIRepresentation = (title: String, description: String)

        var uiRepresentation: UIRepresentation {
            let title: String
            let description: String

            switch self {
            case .tryingToOptInForWatchAccount:
                title = "notifications-trying-to-opt-in-for-watch-account-title".localized
                description = "notifications-trying-to-opt-in-for-watch-account-description".localized
            case .tryingToActForAssetWithPendingOptInRequest(let accountName):
                title = "title-error".localized
                description = "ongoing-opt-in-request-description".localized(params: accountName)
            case .tryingToActForAssetWithPendingOptOutRequest(let accountName):
                title = "title-error".localized
                description = "ongoing-opt-out-request-description".localized(params: accountName)
            case .accountNotFound:
                title = "notifications-account-not-found-title".localized
                description = "notifications-account-not-found-description".localized
            case .assetNotFound:
                title = "notifications-asset-not-found-title".localized
                description = "notifications-asset-not-found-description".localized
            default:
                preconditionFailure("Error mapping must be done properly.")
            }

            return UIRepresentation(
                title: title,
                description: description
            )
        }

        static func == (
            lhs: Self,
            rhs: Self
        ) -> Bool {
            switch (lhs, rhs) {
            case (.waitingForAccountsToBeAvailable, .waitingForAccountsToBeAvailable):
                return true
            case (.waitingForAssetsToBeAvailable, .waitingForAssetsToBeAvailable):
                return true
            case (.tryingToOptInForWatchAccount, .tryingToOptInForWatchAccount):
                return true
            case (.tryingToActForAssetWithPendingOptInRequest(let accountName1), .tryingToActForAssetWithPendingOptInRequest(let accountName2)):
                return accountName1 == accountName2
            case (.tryingToActForAssetWithPendingOptOutRequest(let accountName1), .tryingToActForAssetWithPendingOptOutRequest(let accountName2)):
                return accountName1 == accountName2
            case (.accountNotFound, .accountNotFound):
                return true
            case (.assetNotFound, .assetNotFound):
                return true
            default:
                return false
            }
        }
    }
}

extension DeepLinkParser {
    enum NotificationAction: String {
        case assetOptIn = "asset/opt-in"
        case assetTransactions = "asset/transactions"
    }
}
