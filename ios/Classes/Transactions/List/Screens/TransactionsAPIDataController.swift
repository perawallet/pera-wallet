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
    private var pendingTransactionPolling: PollingOperation?
    private var fetchRequest: EndpointOperatable?
    private var nextToken: String?
    private let paginationRequestThreshold = 5

    private var contacts = [Contact]()
    private var transactions = [TransactionItem]()
    private var pendingTransactions = [PendingTransaction]()

    private let api: ALGAPI
    private var draft: TransactionListing
    private var filterOption: TransactionFilterViewController.FilterOption
    private let sharedDataController: SharedDataController

    private var lastSnapshot: Snapshot?

    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.transactionsController")

    private lazy var rewardCalculator = RewardCalculator(
        api: api,
        account: draft.accountHandle.value,
        sharedDataController: sharedDataController
    )

    private var reward: Decimal = 0

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

        if draft.type == .algos {
            rewardCalculator.delegate = self
        }
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
                    let updatedPendingTransactions = pendingTransactionList.pendingTransactions
                    if !self.pendingTransactions.isEmpty && updatedPendingTransactions.isEmpty {
                        self.pendingTransactions = []
                        return
                    }

                    self.pendingTransactions = updatedPendingTransactions
                    self.deliverContentSnapshot()
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
        let dates = getTransactionFilterDates()
        var assetId: String?
        if let id = draft.compoundAsset?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: draft.accountHandle.value, dates: dates, nextToken: nil, assetId: assetId, limit: 30)
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
                transactionResults.transactions.forEach { $0.status = .completed }

                self.fetchAssets(from: transactionResults.transactions) {
                    self.groupTransactionsByType(transactionResults.transactions, isPaginated: false)
                    self.deliverContentSnapshot()
                }
            }
        }
    }

    private func fetchAssets(
        from transactions: [Transaction],
        completion handler: @escaping EmptyHandler
    ) {
        var assetsToBeFetched: [AssetID] = []

        let assets = transactions.compactMap {
            $0.assetTransfer?.assetId
        }

        for asset in assets {
            if sharedDataController.assetDetailCollection[asset] == nil {
                assetsToBeFetched.append(asset)
            }
        }

        if assetsToBeFetched.isEmpty {
            handler()
            return
        }

        api.fetchAssetDetails(
            AssetFetchQuery(ids: assetsToBeFetched),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] assetResponse in
            guard let self = self else {
                return
            }

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

    func loadNextTransactions() {
        let dates = getTransactionFilterDates()
        var assetId: String?
        if let id = draft.compoundAsset?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: draft.accountHandle.value, dates: dates, nextToken: nextToken, assetId: assetId, limit: 30)
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
                transactionResults.transactions.forEach { $0.status = .completed }

                self.fetchAssets(from: transactionResults.transactions) {
                    self.groupTransactionsByType(transactionResults.transactions, isPaginated: true)
                    self.deliverContentSnapshot()
                }
            }
        }
    }

    func getTransactionFilterDates() -> (from: Date?, to: Date?) {
        switch filterOption {
        case .allTime:
            return (nil, nil)
        case .today:
            return (Date().dateAt(.startOfDay), Date().dateAt(.endOfDay))
        case .yesterday:
            let yesterday = Date().dateAt(.yesterday)
            let endOfYesterday = yesterday.dateAt(.endOfDay)
            return (yesterday, endOfYesterday)
        case .lastWeek:
            let prevOfLastWeek = Date().dateAt(.prevWeek)
            let endOfLastWeek = prevOfLastWeek.dateAt(.endOfWeek)
            return (prevOfLastWeek, endOfLastWeek)
        case .lastMonth:
            let prevOfLastMonth = Date().dateAt(.prevMonth)
            let endOfLastMonth = prevOfLastMonth.dateAt(.endOfMonth)
            return (prevOfLastMonth, endOfLastMonth)
        case let .customRange(from, to):
            return (from, to)
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
                if updatedAccountHandle.value.amount != draft.accountHandle.value.amount ||
                    updatedAccountHandle.value.rewards != draft.accountHandle.value.rewards ||
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
    private func groupTransactionsByType(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        switch draft.type {
        case .algos:
            groupAlgoTransactions(
                transactions,
                isPaginated: isPaginated
            )
        case .asset:
            groupAssetTransactions(
                transactions,
                isPaginated: isPaginated
            )
        case .all:
            groupAllTransactions(
                transactions,
                isPaginated: isPaginated
            )
        }
    }

    private func groupAlgoTransactions(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        let filteredTransactions = transactions.filter { transaction in
            if transaction.isAssetAdditionTransaction(for: draft.accountHandle.value.address) {
                return true
            }

            return transaction.payment != nil
        }

        if api.session.rewardDisplayPreference == .allowed {
            setTransactionsWithRewards(
                filteredTransactions,
                isPaginated: isPaginated
            )
            return
        }


        setTransactionItems(
            filteredTransactions,
            isPaginated: isPaginated
        )
    }

    private func groupAssetTransactions(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        let filteredTransactions = transactions.filter { transaction in
            guard let assetId = transaction.assetTransfer?.assetId,
                  !transaction.isAssetCreationTransaction(for: draft.accountHandle.value.address) else {
                return false
            }

            return assetId == draft.compoundAsset?.id
        }

        setTransactionItems(
            filteredTransactions,
            isPaginated: isPaginated
        )
    }

    private func groupAllTransactions(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        let filteredTransactions = transactions.filter { transaction in
            return transaction.type == .assetTransfer || transaction.type == .payment
        }

        if api.session.rewardDisplayPreference == .allowed {
            setTransactionsWithRewards(
                filteredTransactions,
                isPaginated: isPaginated
            )
            return
        }

        setTransactionItems(
            filteredTransactions,
            isPaginated: isPaginated
        )
    }

    private func setTransactionsWithRewards(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        var transactionsWithRewards: [TransactionItem] = []

        for transaction in transactions {
            transactionsWithRewards.append(transaction)
            if let rewards = transaction.getRewards(for: draft.accountHandle.value.address),
               rewards > 0 {
                let reward = Reward(
                    transactionID: transaction.id,
                    amount: UInt64(rewards),
                    date: transaction.date
                )
                transactionsWithRewards.append(reward)
            }
        }

        setTransactionItems(
            transactionsWithRewards,
            isPaginated: isPaginated
        )
    }

    private func setTransactionItems(
        _ newTransactions: [TransactionItem],
        isPaginated: Bool
    ) {
        self.transactions = isPaginated ? self.transactions + newTransactions : newTransactions
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

            if self.draft is AccountTransactionListing {
                snapshot.appendItems(
                    [.empty(.transactionHistoryLoading)],
                    toSection: .empty
                )
            } else {

                if self.draft.type == .algos {
                    snapshot.appendItems(
                        [
                            .empty(.algoTransactionHistoryLoading),
                            .empty(.transactionHistoryLoading)
                        ],
                        toSection: .empty
                    )
                } else if self.draft.type == .asset {
                    snapshot.appendItems(
                        [
                            .empty(.assetTransactionHistoryLoading),
                            .empty(.transactionHistoryLoading)
                        ],
                        toSection: .empty
                    )
                }
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

            switch self.draft.type {
            case .asset:
                snapshot.appendSections([.info])
                snapshot.appendItems(
                    [.assetInfo(AssetDetailInfoViewModel(self.draft.accountHandle.value, self.draft.compoundAsset!.detail, self.sharedDataController.currency.value))],
                    toSection: .info
                )
            case .algos:
                snapshot.appendSections([.info])
                snapshot.appendItems(
                    [.algosInfo(
                        AlgosDetailInfoViewModel(
                            self.draft.accountHandle.value,
                            self.sharedDataController.currency.value,
                            self.reward
                        )
                    )],
                    toSection: .info
                )
            case .all:
                break
            }

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
            let pendingTransactionsItems: [TransactionsItem] = pendingTransactions.map {
                let viewModel = composePendingTransactionItemViewModel(with: $0, for: $0.receiver == draft.accountHandle.value.address ? $0.sender : $0.receiver)
                return .pending(viewModel)
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
            self.publish(.didUpdate(newSnapshot))
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

                    if let assetTransaction = transaction.assetTransfer {
                        let viewModel = composeTransactionItemViewModel(
                            with: transaction,
                            for: assetTransaction.receiverAddress == draft.accountHandle.value.address ? transaction.sender : assetTransaction.receiverAddress
                        )

                        if addedItemIDs[transactionID] == nil {
                            transactionItems.append(.transaction(viewModel))
                            addedItemIDs[transactionID] = true
                        }
                    } else if let payment = transaction.payment {
                        let viewModel = composeTransactionItemViewModel(
                            with: transaction,
                            for: payment.receiver == draft.accountHandle.value.address ? transaction.sender : transaction.payment?.receiver
                        )

                        if addedItemIDs[transactionID] == nil {
                            transactionItems.append(.transaction(viewModel))
                            addedItemIDs[transactionID] = true
                        }
                    }
                } else if let reward = transaction as? Reward {
                    guard let transactionID = reward.transactionID else {
                        continue
                    }

                    if addedItemIDs[transactionID] == nil {
                        transactionItems.append(.reward(TransactionHistoryContextViewModel(reward)))
                        addedItemIDs[transactionID] = true
                    }
                }
            }
        }

        return transactionItems
    }
}

extension TransactionsAPIDataController {
    private func composeTransactionItemViewModel(
        with transaction: Transaction,
        for address: String?
    ) -> TransactionHistoryContextViewModel {
        var assetDetail: AssetInformation?
        if let assetID = transaction.assetTransfer?.assetId,
           let asset = sharedDataController.assetDetailCollection[assetID] {
            assetDetail = asset
        }

        if let contact = contacts.first(where: { contact in
            contact.address == address
        }) {
            transaction.contact = contact

            let config = TransactionViewModelDependencies(
                account: draft.accountHandle.value,
                assetDetail: assetDetail,
                transaction: transaction,
                contact: contact,
                currency: sharedDataController.currency.value,
                localAccounts: sharedDataController.accountCollection.sorted().map { $0.value }
            )

            return TransactionHistoryContextViewModel(config)
        }

        let config = TransactionViewModelDependencies(
            account: draft.accountHandle.value,
            assetDetail: assetDetail,
            transaction: transaction,
            currency: sharedDataController.currency.value,
            localAccounts: sharedDataController.accountCollection.sorted().map { $0.value }
        )

        return TransactionHistoryContextViewModel(config)
    }

    private func composePendingTransactionItemViewModel(
        with transaction: PendingTransaction,
        for address: String?
    ) -> TransactionHistoryContextViewModel {
        if let contact = contacts.first(where: { contact  in
            contact.address == address
        }) {
            transaction.contact = contact
            let config = TransactionViewModelDependencies(
                account: draft.accountHandle.value,
                assetDetail: draft.compoundAsset?.detail,
                transaction: transaction,
                contact: contact,
                currency: sharedDataController.currency.value,
                localAccounts: sharedDataController.accountCollection.sorted().map { $0.value }
            )

            return TransactionHistoryContextViewModel(config)
        }

        let config = TransactionViewModelDependencies(
            account: draft.accountHandle.value,
            assetDetail: draft.compoundAsset?.detail,
            transaction: transaction,
            currency: sharedDataController.currency.value,
            localAccounts: sharedDataController.accountCollection.sorted().map { $0.value }
        )

        return TransactionHistoryContextViewModel(config)
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

extension TransactionsAPIDataController: RewardCalculatorDelegate {
    func rewardCalculator(_ rewardCalculator: RewardCalculator, didCalculate rewards: Decimal) {
        guard rewards != self.reward else {
            return
        }

        self.reward = rewards
        self.deliverContentSnapshot()
    }
}
