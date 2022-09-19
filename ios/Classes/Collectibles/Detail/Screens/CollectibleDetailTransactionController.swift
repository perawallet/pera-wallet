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

final class CollectibleDetailTransactionController {
    lazy var eventHandlers = Event()

    private let account: Account
    private let asset: CollectibleAsset
    private let transactionController: TransactionController
    private let sharedDataController: SharedDataController

    init(
        account: Account,
        asset: CollectibleAsset,
        transactionController: TransactionController,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.asset = asset
        self.transactionController = transactionController
        self.sharedDataController = sharedDataController
    }
}

extension CollectibleDetailTransactionController {
    func optOutAsset() {
        guard let creator = asset.creator else {
            return
        }

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let request = OptOutBlockchainRequest(account: account, asset: asset)
        monitor.startMonitoringOptOutUpdates(request)

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

    func optInToAsset() {
        let monitor = self.sharedDataController.blockchainUpdatesMonitor
        let request = OptInBlockchainRequest(account: account, asset: asset)
        monitor.startMonitoringOptInUpdates(request)

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            assetIndex: asset.id
        )
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

        eventHandlers.didStartOptingInToAsset?()

        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension CollectibleDetailTransactionController {
    struct Event {
        var didStartRemovingAsset: EmptyHandler?
        var didStartOptingInToAsset: EmptyHandler?
    }
}
