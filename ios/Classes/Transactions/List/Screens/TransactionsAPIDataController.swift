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
//   TransactionsAPIDataController.swift

import Foundation
import MacaroonUIKit
import UIKit
import MacaroonUtils
import MagpieCore

final class TransactionsAPIDataController:
    TransactionsDataController,
    SharedDataControllerObserver {
    var eventHandler: ((TransactionsDataControllerEvent) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()

    private var pendingTransactionPolling: PollingOperation?
    private var fetchRequest: EndpointOperatable?
    private var nextToken: String?
    private let paginationRequestThreshold = 5

    private var contacts = [Contact]()
    private var transactions = [TransactionItem]()
    private var pendingTransactions = [PendingTransaction]()

    private let api: ALGAPI
    private var draft: TransactionListing
    private(set) var filterOption: TransactionFilterViewController.FilterOption
    private let sharedDataController: SharedDataController

    private var lastSnapshot: Snapshot?

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.transactions.updates",
        qos: .userInitiated
    )
    private lazy var pendingTransactionsUpdateQueue = DispatchQueue(
        label: "pera.queue.pendingTransactions.updates",
        qos: .userInitiated
    )

    init(
        _ api: ALGAPI,
        _ draft: TransactionListing,
        _ filterOption: TransactionFilterViewController.FilterOption,
        _ sharedDataController: SharedDataController
    ) {
        self.api = api
        self.draft = draft
        self.filterOption = filterOption
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript (id: String?) -> Transaction? {
        return id.unwrap {
            let transactions = transactions.compactMap { $0 as? Transaction }
            return transactions.first(matching: (\.id, $0))
        }
    }
}

extension TransactionsAPIDataController {
    func load() {
        sharedDataController.add(self)
        deliverLoadingSnapshot()
    }

    func clear() {
        nextToken = nil
        fetchRequest = nil
        transactions.removeAll()
        pendingTransactions.removeAll()
    }

    func shouldSendPaginatedRequest(at index: Int) -> Bool {
        if transactions.count < paginationRequestThreshold {
            return index == transactions.count - 1 && nextToken != nil
        }

        return index == transactions.count - paginationRequestThreshold && nextToken != nil
    }

    func updateFilterOption(_ filterOption: TransactionFilterViewController.FilterOption) {
        self.filterOption = filterOption
    }
}

extension TransactionsAPIDataController {
    func loadContacts() {
        Contact.fetchAll(entity: Contact.entityName) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }

                self.contacts = results
            default:
                break
            }
        }
    }
}

extension TransactionsAPIDataController {
    func startPendingTransactionPolling() {
        pendingTransactionPolling = PollingOperation(interval: 0.8) { [weak self] in
            guard let self = self else {
                return
            }

            self.api.fetchPendingTransactions(self.draft.accountHandle.value.address) { [weak self] response in
                guard let self = self else {
                    return
                }
                switch response {
                case let .success(pendingTransactionList):
                    pendingTransactionsUpdateQueue.async {
                        [weak self] in
                        guard let self else { return }

                        var pendingTransactionsSet = Set<PendingTransaction>()

                        let updatedPendingTransactions = pendingTransactionList.pendingTransactions.filter {
                            let isInserted = pendingTransactionsSet.insert($0).inserted

                            if let assetID = self.draft.asset?.id {
                                return isInserted && $0.assetID == assetID
                            }

                            return isInserted
                        }

                        self.pendingTransactions = updatedPendingTransactions

                        if !updatedPendingTransactions.isEmpty {
                            self.deliverContentSnapshot()
                        }
                    }
                case .failure:
                    /// <todo> Handle error case
                    break
                }
            }
        }

        pendingTransactionPolling?.start()
    }

    func stopPendingTransactionPolling() {
        pendingTransactionPolling?.invalidate()
    }
}

extension TransactionsAPIDataController {
    func loadTransactions() {
        var assetId: String?
        if let id = draft.asset?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(
            account: draft.accountHandle.value,
            dates: filterOption.getDateRanges(),
            nextToken: nil,
            assetId: assetId,
            limit: 30,
            transactionType: draft.type.currentTransactionType
        )

        fetchRequest = api.fetchTransactions(draft) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case .failure:
                /// <todo> Handle error case
                break
            case let .success(transactionResults):
                self.nextToken = self.nextToken == nil ? transactionResults.nextToken : self.nextToken
                transactionResults.transactions.forEach {
                    $0.setAllParentID($0.id)
                    $0.completeAll()
                }

                self.fetchAssets(from: transactionResults.transactions) {
                    self.groupAndSetTransactionsByTypeIfNeeded(
                        transactionResults.transactions,
                        isPaginated: false
                    )
                    self.deliverContentSnapshot()
                }
            }
        }
    }

    private func fetchAssets(
        from transactions: [Transaction],
        completion handler: @escaping EmptyHandler
    ) {
        /// <todo>
        /// This may turn out an expensive operation depending on the how complex transactions are;
        /// thus, we should consider this constraint when refactoring the screen.
        let assetIDs = formUniqueAssetIDs(for: transactions)

        if assetIDs.isEmpty {
            handler()
            return
        }

        let draft = AssetFetchQuery(ids: assetIDs, includeDeleted: true)
        api.fetchAssetDetails(
            draft,
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] assetResponse in
            guard let self else { return }

            switch assetResponse {
            case let .success(assetDetailResponse):
                assetDetailResponse.results.forEach {
                    self.sharedDataController.assetDetailCollection[$0.id] = $0
                }

                handler()
            case .failure:
                handler()
            }
        }
    }

    private func formUniqueAssetIDs(for transactions: [Transaction]) -> [AssetID] {
        let uniqueAssetIDs = transactions.reduce(into: Set<AssetID>()) {
            let uniqueAssetIDsPerTransaction = formUniqueAssetIDs(for: $1)
            $0.formUnion(uniqueAssetIDsPerTransaction)
        }
        return Array(uniqueAssetIDs)
    }

    private func formUniqueAssetIDs(for transaction: Transaction) -> [AssetID] {
        func assetNotExists(forID id: AssetID) -> Bool {
            return sharedDataController.assetDetailCollection[id] == nil
        }

        var uniqueAssetIDs = Set<AssetID>()

        if let assetID = (transaction.assetFreeze?.assetId).unwrap(where: assetNotExists) {
            uniqueAssetIDs.insert(assetID)
        }

        if let assetID = (transaction.assetTransfer?.assetId).unwrap(where: assetNotExists) {
            uniqueAssetIDs.insert(assetID)
        }

        if let assetIDs = transaction.applicationCall?.foreignAssets?.filter(assetNotExists) {
            uniqueAssetIDs.formUnion(assetIDs)
        }

        if let innerTransactions = transaction.innerTransactions.unwrap(where: \.isNonEmpty) {
            let assetIDs = formUniqueAssetIDs(for: innerTransactions)
            uniqueAssetIDs.formUnion(assetIDs)
        }

        return Array(uniqueAssetIDs)
    }

    func loadNextTransactions() {
        var assetId: String?
        if let id = draft.asset?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(
            account: draft.accountHandle.value,
            dates: filterOption.getDateRanges(),
            nextToken: nextToken,
            assetId: assetId,
            limit: 30,
            transactionType: draft.type.currentTransactionType
        )

        fetchRequest = api.fetchTransactions(draft) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case .failure:
                /// <todo> Handle error case
                break
            case let .success(transactionResults):
                self.nextToken = transactionResults.nextToken
                transactionResults.transactions.forEach {
                    $0.setAllParentID($0.id)
                    $0.completeAll()
                }


                self.fetchAssets(from: transactionResults.transactions) {
                    self.groupAndSetTransactionsByTypeIfNeeded(
                        transactionResults.transactions,
                        isPaginated: true
                    )
                    self.deliverContentSnapshot()
                }
            }
        }
    }
}

extension TransactionsAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case let .didStartRunning(first):
            if first ||
               lastSnapshot == nil {
                deliverLoadingSnapshot()
            }
        case .didFinishRunning:
            if let updatedAccountHandle = sharedDataController.accountCollection[draft.accountHandle.value.address] {
                if updatedAccountHandle.value.algo.amount != draft.accountHandle.value.algo.amount ||
                    updatedAccountHandle.value.hasDifferentAssets(than: draft.accountHandle.value) ||
                    updatedAccountHandle.value.hasDifferentApps(than: draft.accountHandle.value) {
                    draft.accountHandle = updatedAccountHandle
                    loadTransactions()
                }
            }
        default:
            break
        }
    }
}

extension TransactionsAPIDataController {
    private func groupAndSetTransactionsByTypeIfNeeded(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        switch draft.type {
        case .algos:
            setTransactionItems(transactions)
        case .asset:
            setTransactionItems(transactions)
        case .all:
            let allTransactionGrouping = AllTransactionListGrouping()
            let groupedTransactions = allTransactionGrouping.groupTransactions(transactions)
            setTransactionItems(groupedTransactions)
        }

        func setTransactionItems(
            _ newTransactions: [TransactionItem]
        ) {
            self.transactions = isPaginated ? self.transactions + newTransactions : newTransactions
        }
    }
}

extension TransactionsAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot { [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()
            snapshot.appendSections([.empty])

            switch self.draft.type {
            case .all:
                snapshot.appendItems(
                    [.empty(.transactionHistoryLoading)],
                    toSection: .empty
                )
            case .algos:
                snapshot.appendItems(
                    [
                        .empty(.transactionHistoryLoading)
                    ],
                    toSection: .empty
                )
            case .asset:
                snapshot.appendItems(
                    [
                        .empty(.transactionHistoryLoading)
                    ],
                    toSection: .empty
                )
            }

            return snapshot
        }
    }
    
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            snapshot.appendSections([.transactionHistory])
            snapshot.appendItems(
                [.filter(TransactionHistoryFilterViewModel(self.filterOption))],
                toSection: .transactionHistory
            )

            let transactionItems = self.getTransactionHistoryItemsWithDates()
            self.appendPendingTransactions(to: &snapshot)

            if self.pendingTransactions.isEmpty,
               transactionItems.isEmpty {
                snapshot.appendSections([.empty])
                snapshot.appendItems([.empty(.noContent)], toSection: .empty)
            }

            snapshot.appendItems(
                transactionItems,
                toSection: .transactionHistory
            )

            return snapshot
        }
    }

    private func appendPendingTransactions(
        to snapshot: inout Snapshot
    ) {
        if !pendingTransactions.isEmpty {
            let pendingTransactionsItems: [TransactionsItem] = pendingTransactions.compactMap { transaction in
                let viewModelDraftComposer = PendingTransactionItemDraftComposer(
                    draft: draft,
                    sharedDataController: sharedDataController,
                    contacts: contacts
                )

                guard let draft = viewModelDraftComposer.composeTransactionItemPresentationDraft(from: transaction) else {
                    return nil
                }

                let viewModel = PendingTransactionItemViewModel(
                    draft,
                    currency: sharedDataController.currency,
                    currencyFormatter: currencyFormatter
                )
                return .pendingTransaction(viewModel)
            }

            snapshot.appendItems(
                [.title(TransactionHistoryTitleContextViewModel( title: "transaction-detail-pending-transactions".localized))] + pendingTransactionsItems,
                toSection: .transactionHistory
            )
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()

            self.lastSnapshot = newSnapshot
            self.publish(.didUpdateSnapshot(newSnapshot))
        }
    }
}

extension TransactionsAPIDataController {
    private func getTransactionHistoryItemsWithDates() -> [TransactionsItem] {
        var transactionItems: [TransactionsItem] = []
        var addedItemIDs: [String: Bool] = [:]

        if var currentDate = transactions.first?.date?.toFormat("MMM d, yyyy") {
            let item: TransactionsItem = .title(TransactionHistoryTitleContextViewModel(title: currentDate))

            if addedItemIDs[currentDate] == nil {
                transactionItems.append(item)
                addedItemIDs[currentDate] = true
            }

            for transaction in transactions {
                if let transactionDate = transaction.date,
                   transactionDate.toFormat("MMM d, yyyy") != currentDate {

                    let newDate = transactionDate.toFormat("MMM d, yyyy")

                    let item: TransactionsItem = .title(TransactionHistoryTitleContextViewModel(title: newDate))

                    if addedItemIDs[newDate] == nil {
                        transactionItems.append(item)
                        addedItemIDs[newDate] = true
                        currentDate = newDate
                    }
                }

                if let transaction = transaction as? Transaction {
                    guard let transactionID = transaction.id else {
                        continue
                    }

                    switch transaction.type {
                    case .payment:
                        let draftComposer = AlgoTransactionItemDraftComposer(
                            draft: draft,
                            sharedDataController: sharedDataController,
                            contacts: contacts
                        )

                        guard let viewModelDraft = draftComposer.composeTransactionItemPresentationDraft(from: transaction) else {
                            continue
                        }

                        let viewModel = AlgoTransactionItemViewModel(
                            viewModelDraft,
                            currency: sharedDataController.currency,
                            currencyFormatter: currencyFormatter
                        )

                        if addedItemIDs[transactionID] == nil {
                            transactionItems.append(.algoTransaction(viewModel))
                            addedItemIDs[transactionID] = true
                        }
                    case .assetTransfer:
                        let draftComposer = AssetTransactionItemDraftComposer(
                            draft: draft,
                            sharedDataController: sharedDataController,
                            contacts: contacts
                        )

                        guard let viewModelDraft = draftComposer.composeTransactionItemPresentationDraft(from: transaction) else {
                            continue
                        }

                        let viewModel = AssetTransactionItemViewModel(
                            viewModelDraft,
                            currency: sharedDataController.currency,
                            currencyFormatter: currencyFormatter
                        )

                        if addedItemIDs[transactionID] == nil {
                            transactionItems.append(.assetTransaction(viewModel))
                            addedItemIDs[transactionID] = true
                        }
                    case .assetConfig:
                        let draftComposer = AssetConfigTransactionItemDraftComposer(draft: draft)

                        guard let viewModelDraft = draftComposer.composeTransactionItemPresentationDraft(from: transaction) else {
                            continue
                        }

                        let viewModel = AssetConfigTransactionItemViewModel(viewModelDraft)

                        if addedItemIDs[transactionID] == nil {
                            transactionItems.append(.assetConfigTransaction(viewModel))
                            addedItemIDs[transactionID] = true
                        }
                    case .applicationCall:
                        let draftComposer = AppCallTransactionItemDraftComposer(draft: draft)

                        guard let viewModelDraft = draftComposer.composeTransactionItemPresentationDraft(from: transaction) else {
                            continue
                        }

                        let viewModel = AppCallTransactionItemViewModel(viewModelDraft)

                        if addedItemIDs[transactionID] == nil {
                            transactionItems.append(.appCallTransaction(viewModel))
                            addedItemIDs[transactionID] = true
                        }
                    default:
                        break
                    }
                }
            }
        }

        return transactionItems
    }
}

extension TransactionsAPIDataController {
    private func publish(
        _ event: TransactionsDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
