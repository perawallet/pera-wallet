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
        switch notification.detail?.type {
        case .transactionSent,
             .transactionReceived:
            return makeTransactionDetailScreen(for: notification)
        case .assetTransactionSent,
             .assetTransactionReceived,
             .assetSupportSuccess:
            return makeAssetTransactionDetailScreen(for: notification)
        case .assetSupportRequest:
            return makeAssetTransactionRequestScreen(for: notification)
        default:
            return nil
        }
    }
    
    private func makeTransactionDetailScreen(
        for notification: AlgorandNotification
    ) -> Result? {
        guard let accountAddress = notification.accountAddress else {
            return nil
        }
        
        guard
            let account = sharedDataController.accountCollection[accountAddress],
            account.isAvailable,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAccountsToBeAvailable)
        }

        let rawAccount = account.value
        return .success(.asaDetail(account: rawAccount, asset: rawAccount.algo))
    }
    
    private func makeAssetTransactionDetailScreen(
        for notification: AlgorandNotification
    ) -> Result? {
        guard
            let accountAddress = notification.accountAddress,
            let assetId = notification.detail?.asset?.id
        else {
            return nil
        }
        
        guard
            let account = sharedDataController.accountCollection[accountAddress],
            account.isAvailable,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        guard let asset = account.value[assetId] as? StandardAsset else {
            return .failure(.waitingForAssetsToBeAvailable)
        }

        return .success(.asaDetail(account: account.value, asset: asset))
    }
    
    private func makeAssetTransactionRequestScreen(
        for notification: AlgorandNotification
    ) -> Result? {
        guard
            let accountAddress = notification.accountAddress,
            let assetId = notification.detail?.asset?.id
        else {
            return nil
        }
        
        guard
            let account = sharedDataController.accountCollection[accountAddress],
            account.isAvailable,
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAccountsToBeAvailable)
        }
        
        let accountName = account.value.name ?? accountAddress
        let draft = AssetAlertDraft(
            account: account.value,
            assetId: assetId,
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
        case actionSelection(address: String, label: String?)
        case assetActionConfirmation(
            draft: AssetAlertDraft,
            theme: AssetActionConfirmationViewControllerTheme = .init()
        )
        case asaDetail(account: Account, asset: Asset)
        case sendTransaction(
            draft: QRSendTransactionDraft,
            shouldFilterAccount: ((Account) -> Bool)? = nil
        )
        case wcMainTransactionScreen(draft: WalletConnectRequestDraft)
        case buyAlgo(draft: BuyAlgoDraft)
        case accountSelect(asset: AssetID)
    }
    
    enum Error: Swift.Error {
        case waitingForAccountsToBeAvailable
        case waitingForAssetsToBeAvailable
    }
}
