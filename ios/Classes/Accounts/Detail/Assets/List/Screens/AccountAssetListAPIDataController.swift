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
//   AccountAssetListAPIDataController.swift

import Foundation
import MacaroonUtils

final class AccountAssetListAPIDataController:
    AccountAssetListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AccountAssetListDataControllerEvent) -> Void)?

    private(set) var account: AccountHandle

    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()
    private lazy var searchThrottler = createSearchThrottler()

    private lazy var currencyFormatter = createCurrencyFormatter()
    private lazy var assetAmountFormatter = createAssetAmountFormatter()
    private lazy var minBalanceCalculator = createMinBalanceCalculator()

    private var accountNotBackedUpWarningViewModel: AccountDetailAccountNotBackedUpWarningModel?

    private var nextQuery: AccountAssetListQuery?
    private var lastQuery: AccountAssetListQuery?
    private var lastSnapshot: Snapshot?

    private var canDeliverUpdatesForAssets = false

    private let sharedDataController: SharedDataController

    init(
        account: AccountHandle,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.sharedDataController = sharedDataController
    }

    deinit {
        cancelOngoingSearching()
        sharedDataController.remove(self)
    }
}

extension AccountAssetListAPIDataController {
    func load(query: AccountAssetListQuery?) {
        nextQuery = query

        if canDeliverUpdatesForAssets {
            loadNext(query: query)
        } else {
            loadFirst(query: query)
        }
    }

    private func loadNext(query: AccountAssetListQuery?) {
        if query == lastQuery {
            nextQuery = nil
            return
        }

        if query?.keyword == lastQuery?.keyword {
            customize(query: query)
        } else {
            search(query: query)
        }
    }

    private func customize(query: AccountAssetListQuery?) {
        cancelOngoingSearching()
        deliverUpdatesForLoading(for: .customize)

        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { query == self.nextQuery },
                query: query,
                for: .customize
            )
        }
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }

    private func search(query: AccountAssetListQuery?) {
        cancelOngoingLoading()
        deliverUpdatesForLoading(for: .search)

        searchThrottler.performNext {
            [weak self] in
            guard let self else { return }

            let task = AsyncTask {
                [weak self] completionBlock in
                guard let self else { return }

                defer {
                    completionBlock()
                }

                self.deliverUpdatesForContent(
                    when: { query == self.nextQuery },
                    query: query,
                    for: .search
                )
            }
            self.asyncLoadingQueue.add(task)
            self.asyncLoadingQueue.resume()
        }
    }

    private func loadFirst(query: AccountAssetListQuery?) {
        deliverUpdatesForLoading(for: .customize)

        lastQuery = query
        nextQuery = nil
        sharedDataController.add(self)
    }

    func reloadIfNeededForPendingAssetRequests() {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        if monitor.hasAnyPendingOptInRequest(for: account.value) ||
           monitor.hasAnyPendingOptOutRequest(for: account.value) {
            reload()
        }
    }

    func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { self.nextQuery == nil },
                query: self.lastQuery,
                for: .refresh
            )
        }
        asyncLoadingQueue.add(task)
    }

    private func cancelOngoingSearching() {
        searchThrottler.cancelAll()
        cancelOngoingLoading()
    }

    private func cancelOngoingLoading() {
        asyncLoadingQueue.cancel()
    }
}

extension AccountAssetListAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            canDeliverUpdatesForAssets = true

            if let upToDateAccount = sharedDataController.accountCollection[account.value.address] {
                account = upToDateAccount
                reload()
            }
        }
    }
}

extension AccountAssetListAPIDataController {
    private func deliverUpdatesForLoading(for operation: Updates.Operation) {
        if lastSnapshot?.itemIdentifiers(inSection: .assets).last == .assetLoading {
            return
        }

        let updates = makeUpdatesForLoading(for: operation)
        publish(updates: updates)
    }

    private func makeUpdatesForLoading(for operation: Updates.Operation) -> Updates {
        var snapshot = Snapshot()
        appendSectionsForAccountNotBackedUpWarningIfNeeded(into: &snapshot)
        appendSectionsForPortfolio(into: &snapshot)
        appendSectionsIfNeededForQuickActions(into: &snapshot)
        appendSectionsForAssetsLoading(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
    }

    private func deliverUpdatesForContent(
        when condition: () -> Bool,
        query: AccountAssetListQuery?,
        for operation: Updates.Operation
    ) {
        let updates = makeUpdatesForContent(
            query: query,
            for: operation
        )

        if !condition() { return }

        self.lastQuery = query
        self.nextQuery = nil
        self.publish(updates: updates)
    }

    private func makeUpdatesForContent(
        query: AccountAssetListQuery?,
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendSectionsForAccountNotBackedUpWarningIfNeeded(into: &snapshot)
        appendSectionsForPortfolio(into: &snapshot)
        appendSectionsIfNeededForQuickActions(into: &snapshot)
        appendSectionsForAssets(
            query: query,
            into: &snapshot
        )
        return Updates(snapshot: snapshot, operation: operation)
    }
}

extension AccountAssetListAPIDataController {
    private func appendSectionsForAccountNotBackedUpWarningIfNeeded(into snapshot: inout Snapshot) {
        guard !account.value.isBackedUp else { return }

        let items = makeItemsForAccountNotBackedUpWarning()
        snapshot.appendSections([ .accountNotBackedUpWarning ])
        snapshot.appendItems(
            items,
            toSection: .accountNotBackedUpWarning
        )
    }

    private func appendSectionsForPortfolio(into snapshot: inout Snapshot) {
        let items = makeItemsForPortfolio()
        snapshot.appendSections([ .portfolio ])
        snapshot.appendItems(
            items,
            toSection: .portfolio
        )
    }

    private func appendSectionsIfNeededForQuickActions(into snapshot: inout Snapshot) {
        let items = makeItemsForQuickActions()

        if items.isEmpty { return }

        snapshot.appendSections([ .quickActions ])
        snapshot.appendItems(
            items,
            toSection: .quickActions
        )
    }

    private func appendSectionsForAssetsLoading(into snapshot: inout Snapshot) {
        let items = makeItemsForAssetsHeader() + makeItemsForAssetsLoading()
        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }

    private func appendSectionsForAssets(
        query: AccountAssetListQuery?,
        into snapshot: inout Snapshot
    ) {
        let assetItems = makeItemsForPendingAssetRequests() + makeItemsForAssets(query: query)

        let items = makeItemsForAssetsHeader() + assetItems
        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )

        if assetItems.isEmpty {
            appendSectionsForNotFound(into: &snapshot)
        }
    }

    private func appendSectionsForNotFound(into snapshot: inout Snapshot) {
        let items = makeItemsForNotFound()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            items,
            toSection: .empty
        )
    }
}

extension AccountAssetListAPIDataController {
    private func makeItemsForAccountNotBackedUpWarning() -> [AccountAssetsItem] {
        let viewModel: AccountDetailAccountNotBackedUpWarningModel
      
        if let accountNotBackedUpWarningViewModel {
            viewModel = accountNotBackedUpWarningViewModel
        } else {
            viewModel = .init()
        }

        return [ .accountNotBackedUpWarning(viewModel) ]
    }

    private func makeItemsForPortfolio() -> [AccountAssetsItem] {
        if account.value.authorization.isWatch {
            return makeItemsForWatchAccountPortfolio()
        } else {
            return makeItemsForNormalAccountPortfolio()
        }
    }

    private func makeItemsForWatchAccountPortfolio() -> [AccountAssetsItem] {
        let currency = sharedDataController.currency
        let portfolio = AccountPortfolioItem(
            accountValue: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let viewModel = WatchAccountPortfolioViewModel(portfolio)
        return [ .watchPortfolio(viewModel) ]
    }

    private func makeItemsForNormalAccountPortfolio() -> [AccountAssetsItem] {
        let currency = sharedDataController.currency
        let calculatedMinimumBalance = minBalanceCalculator.calculateMinimumAmount(
            for: account.value,
            with: .algosTransaction,
            calculatedFee: .zero,
            isAfterTransaction: false
        )
        let portfolio = AccountPortfolioItem(
            accountValue: account,
            currency: currency,
            currencyFormatter: currencyFormatter,
            minimumBalance: calculatedMinimumBalance
        )
        let viewModel = AccountPortfolioViewModel(portfolio)
        return [ .portfolio(viewModel) ]
    }

    private func makeItemsForQuickActions() -> [AccountAssetsItem] {
        if account.value.authorization.isWatch {
            return makeItemsForWatchAccountQuickActions()
        } else {
            return makeItemsForNormalAccountQuickActions()
        }
    }

    private func makeItemsForWatchAccountQuickActions() -> [AccountAssetsItem] {
        return [ .watchAccountQuickActions ]
    }

    private func makeItemsForNormalAccountQuickActions() -> [AccountAssetsItem] {
        return [ .quickActions ]
    }

    private func makeItemsForAssetsHeader() -> [AccountAssetsItem] {
        return makeItemsForAssetsHeaderTitle() + makeItemsForSearchBar()
    }

    private func makeItemsForAssetsHeaderTitle() -> [AccountAssetsItem] {
        if account.value.authorization.isWatch {
            return makeItemsForWatchAccountAssetsHeaderTitle()
        } else {
            return makeItemsForNormalAccountAssetsHeaderTitle()
        }
    }

    private func makeItemsForWatchAccountAssetsHeaderTitle() -> [AccountAssetsItem] {
        let viewModel = ManagementItemViewModel(.asset(isWatchAccountDisplay: true))
        return [ .watchAccountAssetManagement(viewModel) ]
    }

    private func makeItemsForNormalAccountAssetsHeaderTitle() -> [AccountAssetsItem] {
        let viewModel = ManagementItemViewModel(.asset(isWatchAccountDisplay: false))
        return [ .assetManagement(viewModel) ]
    }

    private func makeItemsForSearchBar() -> [AccountAssetsItem] {
        return [ .search ]
    }

    private func makeItemsForAssetsLoading() -> [AccountAssetsItem] {
        return [ .assetLoading ]
    }

    private func makeItemsForPendingAssetRequests() -> [AccountAssetsItem] {
        return
            makeItemsForPendingAssetOptInRequests() +
            makeItemsForPendingAssetOptOutRequests() +
            makeItemsForPendingAssetSendRequests()
    }

    private func makeItemsForPendingAssetOptInRequests() -> [AccountAssetsItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let updates = monitor.filterPendingOptInAssetUpdates(for: account.value)
        return updates.map {
            let update = $0.value
            if update.isCollectibleAsset {
                return makeItemForPendingNFTAssetOptInRequest(update)
            } else {
                return makeItemForPendingNonNFTAssetOptInRequest(update)
            }
        }
    }

    private func makeItemForPendingNFTAssetOptInRequest(
        _ update: OptInBlockchainUpdate
    ) -> AccountAssetsItem {
        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(item)
    }

    private func makeItemForPendingNonNFTAssetOptInRequest(
        _ update: OptInBlockchainUpdate
    ) -> AccountAssetsItem {
        let item = AccountAssetsPendingAssetListItem(update: update)
        return .pendingAsset(item)
    }

    private func makeItemsForPendingAssetOptOutRequests() -> [AccountAssetsItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let updates = monitor.filterPendingOptOutAssetUpdates(for: account.value)
        return updates.map {
            let update = $0.value
            if update.isCollectibleAsset {
                return makeItemForPendingNFTAssetOptOutRequest(update)
            } else {
                return makeItemForPendingNonNFTAssetOptOutRequest(update)
            }
        }
    }

    private func makeItemForPendingNFTAssetOptOutRequest(
        _ update: OptOutBlockchainUpdate
    ) -> AccountAssetsItem {
        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(item)
    }

    private func makeItemForPendingNonNFTAssetOptOutRequest(
        _ update: OptOutBlockchainUpdate
    ) -> AccountAssetsItem {
        let item = AccountAssetsPendingAssetListItem(update: update)
        return .pendingAsset(item)
    }

    private func makeItemsForPendingAssetSendRequests() -> [AccountAssetsItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let updates = monitor.filterPendingSendPureCollectibleAssetUpdates(for: account.value)
        return updates.map {
            let update = $0.value
            return makeItemForPendingNFTAssetSendRequest(update)
        }
    }

    private func makeItemForPendingNFTAssetSendRequest(
        _ update: SendPureCollectibleAssetBlockchainUpdate
    ) -> AccountAssetsItem {
        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(item)
    }

    private func makeItemsForAssets(query: AccountAssetListQuery?) -> [AccountAssetsItem] {
        let showsOnlyNonNFTAssets = query?.showsOnlyNonNFTAssets ?? false
        let assets = showsOnlyNonNFTAssets ? account.value.standardAssets : account.value.allAssets

        var assetItems: [AccountAssetsItem] = assets.someArray.compactMap {
            asset in
            if let query, !query.matches(asset) {
                return nil
            }

            /// <note>
            /// Pending asset requests has its own item different from the asset item.
            if hasAnyPendingAssetRequest(asset) {
                return nil
            }

            return makeItemForAsset(asset)
        }

        if let query, query.matchesByKeyword(account.value.algo) {
            let item = makeItemForAlgoAsset(account.value.algo)
            assetItems.insert(
                item,
                at: 0
            )
        }

        guard let sortingAlgorithm = query?.sortingAlgorithm else {
            return assetItems
        }

        return assetItems.sorted {
            return sortingAlgorithm.getFormula(
                asset: $0.asset!,
                otherAsset: $1.asset!
            )
        }
    }

    private func makeItemForAsset(_ asset: Asset) -> AccountAssetsItem? {
        switch asset {
        case let nonNFTAsset as StandardAsset: return makeItemForNonNFTAsset(nonNFTAsset)
        case let nftAsset as CollectibleAsset: return makeItemForNFTAsset(nftAsset)
        case let algoAsset as Algo: return makeItemForAlgoAsset(algoAsset)
        default: return nil
        }
    }

    private func makeItemForAlgoAsset(_ algoAsset: Algo) -> AccountAssetsItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: algoAsset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = AccountAssetsAssetListItem(item: assetItem)
        return .asset(item)
    }

    private func makeItemForNonNFTAsset(_ asset: StandardAsset) -> AccountAssetsItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = AccountAssetsAssetListItem(item: assetItem)
        return .asset(item)
    }

    private func makeItemForNFTAsset(_ asset: CollectibleAsset) -> AccountAssetsItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account.value,
            asset: asset,
            amountFormatter: assetAmountFormatter
        )
        let item = AccountAssetsCollectibleAssetListItem(item: collectibleAssetItem)
        return .collectibleAsset(item)
    }

    private func makeItemsForNotFound() -> [AccountAssetsItem] {
        let viewModel = AssetListSearchNoContentViewModel(hasBody: true)
        return [ .empty(viewModel) ]
    }
}

extension AccountAssetListAPIDataController {
    private func hasAnyPendingAssetRequest(_ asset: Asset) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        let hasOptInRequest = monitor.hasPendingOptInRequest(
            assetID: asset.id,
            for: account.value
        )
        if hasOptInRequest {
            return true
        }

        let hasOptOutRequest = monitor.hasPendingOptOutRequest(
            assetID: asset.id,
            for: account.value
        )
        if hasOptOutRequest {
            return true
        }

        let hasSendRequest = monitor.hasPendingSendPureCollectibleAssetRequest(
            assetID: asset.id,
            for: account.value
        )
        if hasSendRequest {
            return true
        }

        return false
    }
}

extension AccountAssetListAPIDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }

    private func publish(event: AccountAssetListDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }
}

extension AccountAssetListAPIDataController {
    private func createAsyncLoadingQueue() -> AsyncSerialQueue {
        let underlyingQueue = DispatchQueue(
            label: "pera.queue.accountAssets.updates",
            qos: .userInitiated
        )
        return .init(
            name: "accountAssetListAPIDataController.asyncLoadingQueue",
            underlyingQueue: underlyingQueue
        )
    }

    private func createSearchThrottler() -> Throttler {
        return .init(intervalInSeconds: 0.4)
    }

    private func createCurrencyFormatter() -> CurrencyFormatter {
        return .init()
    }

    private func createAssetAmountFormatter() -> CollectibleAmountFormatter {
        return .init()
    }

    private func createMinBalanceCalculator() -> TransactionFeeCalculator {
        return .init(transactionDraft: nil, transactionData: nil, params: nil)
    }
}

extension AccountAssetListAPIDataController {
    typealias Updates = AccountAssetListUpdates
    typealias Snapshot = AccountAssetListUpdates.Snapshot
}
