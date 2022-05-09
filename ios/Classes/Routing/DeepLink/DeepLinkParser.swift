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
        
        let draft = AlgoTransactionListing(accountHandle: account)
        return .success(.algosDetail(draft: draft))
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
        
        let draft = AssetTransactionListing(accountHandle: account, asset: asset)
        return .success(.assetDetail(draft: draft))
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
        
        let accountName = account.value.name.someString
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
        url: URL
    ) -> Result? {
        if canDiscover(moonpayTransaction: url) {
            /// note: When moonpay transaction can discoverable, we should return nil  Otherwise It may cause a conflcit on QR discover function
            return nil
        }

        if let result = discover(qr: url) {
            return result
        }

        return nil
    }
    
    private func makeAccountAdditionScreen(
        _ qr: QRText,
        for url: URL
    ) -> Result? {
        let address = extractAccountAddress(from: url)
        return address.unwrap {
            .success(.addContact(address: $0, name: qr.label))
        }
    }
    
    private func makeTransactionRequestScreen(
        _ qr: QRText,
        for url: URL
    ) -> Result? {
        guard let amount = qr.amount else {
            return nil
        }

        guard
            let accountAddress = extractAccountAddress(from: url),
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
        _ qr: QRText,
        for url: URL
    ) -> Result? {
        guard let assetId = qr.asset, let amount = qr.amount else {
            return nil
        }

        guard
            let accountAddress = extractAccountAddress(from: url),
            sharedDataController.isAvailable
        else {
            return .failure(.waitingForAssetsToBeAvailable)
        }

        guard
            let assetDecoration = sharedDataController.assetDetailCollection[assetId]
        else {
            let draft = AssetAlertDraft(
                account: nil,
                assetId: assetId,
                asset: nil,
                title: "asset-support-title".localized,
                detail: "asset-support-error".localized,
                actionTitle: "title-approve".localized,
                cancelTitle: "title-cancel".localized
            )
            return .success(.assetActionConfirmation(draft: draft))
        }

        /// <todo> Support the collectibles later when its detail screen is done.

        let qrDraft = QRSendTransactionDraft(
            toAccount: accountAddress,
            amount: Decimal(amount),
            note: qr.note,
            lockedNote: qr.lockedNote,
            transactionMode: .asset(StandardAsset(asset: ALGAsset(id: assetDecoration.id), decoration: assetDecoration))
        )
        return .success(.sendTransaction(draft: qrDraft))
    }
    
    private func extractAccountAddress(
        from url: URL
    ) -> String? {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let accountAddress = urlComponents?.host
        return accountAddress.unwrap { $0.isValidatedAddress }
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
    private func canDiscover(moonpayTransaction url: URL) -> Bool {
        if let buyAlgoParams = url.extractBuyAlgoParamsFromMoonPay() {
            NotificationCenter.default.post(
                name: .didRedirectFromMoonPay,
                object: self,
                userInfo: [BuyAlgoParams.notificationObjectKey: buyAlgoParams]
            )

            return true
        }

        return false
    }

    private func discover(qr url: URL) -> Result? {
        guard let qr = url.buildQRText() else {
            return nil
        }

        switch qr.mode {
        case .address:
            return makeAccountAdditionScreen(
                qr,
                for: url
            )
        case .algosRequest:
            return makeTransactionRequestScreen(
                qr,
                for: url
            )
        case .assetRequest:
            return makeAssetTransactionRequestScreen(
                qr,
                for: url
            )
        case .mnemonic:
            return nil
        }
    }
}

extension DeepLinkParser {
    typealias Result = Swift.Result<Screen, Error>
    
    enum Screen {
        case addContact(address: String, name: String?)
        case algosDetail(draft: TransactionListing)
        case assetActionConfirmation(draft: AssetAlertDraft)
        case assetDetail(draft: TransactionListing)
        case sendTransaction(draft: QRSendTransactionDraft)
        case wcMainTransactionScreen(draft: WalletConnectRequestDraft)
        case buyAlgo(draft: BuyAlgoDraft)
    }
    
    enum Error: Swift.Error {
        case waitingForAccountsToBeAvailable
        case waitingForAssetsToBeAvailable
    }
}
