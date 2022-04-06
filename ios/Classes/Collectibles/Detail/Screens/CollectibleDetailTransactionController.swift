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

//   CollectibleDetailTransactionController.swift

import Foundation

final class CollectibleDetailTransactionController:
    NSObject,
    AssetActionConfirmationViewControllerDelegate {
    private let account: Account
    private let asset: CollectibleAsset
    private let transactionController: TransactionController

    lazy var eventHandlers = Event()

    private var isValidAssetDeletion: Bool {
        return asset.amountWithFraction == 0
    }

    init(
        account: Account,
        asset: CollectibleAsset,
        transactionController: TransactionController
    ) {
        self.account = account
        self.asset = asset
        self.transactionController = transactionController
    }
}

extension CollectibleDetailTransactionController {
    func createOptOutAlertDraft() -> AssetAlertDraft {
        let assetDecoration = AssetDecoration(asset: asset)

        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetId: assetDecoration.id,
            asset: assetDecoration,
            title: "collectible-detail-opt-out-alert-title".localized(params: asset.title ?? asset.name ?? ""),
            detail: "collectible-detail-opt-out-alert-message".localized(params: account.name ?? account.address.shortAddressDisplay),
            actionTitle: "collectible-detail-opt-out".localized,
            cancelTitle: "title-cancel".localized
        )

        return assetAlertDraft
    }
}

extension CollectibleDetailTransactionController {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        removeAsset()
    }

    private func removeAsset() {
        guard let creator = asset.creator else {
            return
        }

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            toAccount: Account(address: creator.address, type: .standard),
            amount: 0,
            assetIndex: asset.id,
            assetCreator: creator.address
        )
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)

        eventHandlers.didStartRemovingAsset?()

        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension CollectibleDetailTransactionController {
    struct Event {
        var didStartRemovingAsset: EmptyHandler?
    }
}
