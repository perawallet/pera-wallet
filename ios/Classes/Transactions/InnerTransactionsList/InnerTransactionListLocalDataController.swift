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

//   InnerTransactionListLocalDataController.swift

import Foundation
import MacaroonUtils

final class InnerTransactionListLocalDataController:
    InnerTransactionListDataController {
    var eventHandler: ((InnerTransactionListDataControllerEvent) -> Void)?

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.innerTransactions.updates",
        qos: .userInitiated
    )

    private(set) var draft: InnerTransactionListDraft
    private(set) lazy var currencyFormatter = CurrencyFormatter()
    
    private lazy var innerTransactions: [Transaction] = draft.innerTransactions

    private let sharedDataController: SharedDataController
    private let currency: CurrencyProvider

    init(
        draft: InnerTransactionListDraft,
        sharedDataController: SharedDataController,
        currency: CurrencyProvider
    ) {
        self.draft = draft
        self.sharedDataController = sharedDataController
        self.currency = currency
    }
}

extension InnerTransactionListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension InnerTransactionListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            snapshot.appendSections([ .transactions ])

            self.addHeader(&snapshot)
            self.addTransactionItems(&snapshot)

            return snapshot
        }
    }

    private func addHeader(
        _ snapshot: inout Snapshot
    ) {
        let headerItem: InnerTransactionListItem = .header(
            InnerTransactionListHeaderViewModel(
                innerTransactionCount: UInt(innerTransactions.count)
            )
        )

        snapshot.appendItems(
            [headerItem],
            toSection: .transactions
        )
    }

    private func addTransactionItems(
        _ snapshot: inout Snapshot
    ) {
        let innerTransactionItems =
        innerTransactions.compactMap(makeInnerTransactionListItem)

        snapshot.appendItems(
            innerTransactionItems,
            toSection: .transactions
        )
    }

    private func makeInnerTransactionListItem(
        _ transaction: Transaction
    ) -> InnerTransactionListItem? {
        switch transaction.type {
        case .payment:
            let viewModel = AlgoInnerTransactionPreviewViewModel(
                transaction: transaction,
                account: draft.account,
                currency: currency,
                currencyFormatter: currencyFormatter
            )

            let item: InnerTransactionListItem = .algoTransaction(
                InnerTransactionContainer(
                    transaction: transaction,
                    viewModel: viewModel
                )
            )

            return item
        case .assetTransfer:
            let viewModel = AssetInnerTransactionPreviewViewModel(
                transaction: transaction,
                account: draft.account,
                asset: getAsset(from: transaction),
                currency: currency,
                currencyFormatter: currencyFormatter
            )

            let item: InnerTransactionListItem = .assetTransaction(
                InnerTransactionContainer(
                    transaction: transaction,
                    viewModel: viewModel
                )
            )

            return item
        case .assetConfig:
            let viewModel = AssetConfigInnerTransactionPreviewViewModel(transaction)

            let item: InnerTransactionListItem = .assetConfigTransaction(
                InnerTransactionContainer(
                    transaction: transaction,
                    viewModel: viewModel
                )
            )

            return item
        case .applicationCall:
            let viewModel = AppCallInnerTransactionPreviewViewModel(transaction)

            let item: InnerTransactionListItem = .appCallTransaction(
                InnerTransactionContainer(
                    transaction: transaction,
                    viewModel: viewModel
                )
            )
            return item
        case .keyReg:
            let viewModel = KeyRegInnerTransactionPreviewViewModel(transaction)

            let item: InnerTransactionListItem = .keyRegTransaction(
                InnerTransactionContainer(
                    transaction: transaction,
                    viewModel: viewModel
                )
            )
            return item
        default:
            break
        }

        return nil
    }
    
    private func getAsset(from transaction: Transaction) -> Asset? {
        guard let transactionAssetID = transaction.assetTransfer?.assetId,
              let assetDecoration = sharedDataController.assetDetailCollection[transactionAssetID] else {
            return draft.asset
        }
        
        return assetDecoration.isCollectible ?
            CollectibleAsset(decoration: assetDecoration) :
            StandardAsset(decoration: assetDecoration)
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension InnerTransactionListLocalDataController {
    private func publish(
        _ event: InnerTransactionListDataControllerEvent
    ) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}

struct InnerTransactionListDraft {
    let type: TransactionTypeFilter
    let asset: Asset?
    let account: Account
    let innerTransactions: [Transaction]
}
