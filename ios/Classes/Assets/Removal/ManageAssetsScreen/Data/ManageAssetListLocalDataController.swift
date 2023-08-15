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

//   ManageAssetListLocalDataController.swift

import Foundation
import MacaroonUtils

final class ManageAssetListLocalDataController:
    ManageAssetListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((ManageAssetListDataControllerEvent) -> Void)?

    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()
    private lazy var collectibleAmountFormatter = createCollectibleAmountFormatter()
    private lazy var currencyFormatter = createCurrencyFormatter()
    private lazy var searchThrottler = createSearchThrottler()
    
    private(set) var account: Account
    
    private var nextQuery: ManageAssetListQuery?
    private var lastQuery: ManageAssetListQuery?
    private var lastSnapshot: Snapshot?
    
    private var canDeliverUpdatesForAssets = false
    
    private let sharedDataController: SharedDataController

    init(
        account: Account,
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

extension ManageAssetListLocalDataController {
    func load(query: ManageAssetListQuery?) {
        nextQuery = query
        
        if canDeliverUpdatesForAssets {
            loadNext(query: query)
        } else {
            loadFirst(query: query)
        }
    }
    
    func loadNext(query: ManageAssetListQuery?) {
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
    
    func customize(query: ManageAssetListQuery?) {
        cancelOngoingSearching()
        deliverUpdatesForLoading()
        
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }
            
            defer {
                completionBlock()
            }
            
            self.deliverUpdatesForContent(
                when: { query == self.nextQuery },
                query: query
            )
        }
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }
    
    func search(query: ManageAssetListQuery?) {
        cancelOngoingLoading()
        deliverUpdatesForLoading()
        
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
                    query: query
                )
            }
            self.asyncLoadingQueue.add(task)
            self.asyncLoadingQueue.resume()
        }
    }
    
    private func loadFirst(query: ManageAssetListQuery?) {
        deliverUpdatesForLoading()

        lastQuery = query
        nextQuery = nil
        sharedDataController.add(self)
    }
}

extension ManageAssetListLocalDataController {
    private func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }
            
            defer {
                completionBlock()
            }
            
            self.deliverUpdatesForContent(
                when: { self.nextQuery == nil },
                query: self.lastQuery
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

extension ManageAssetListLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            canDeliverUpdatesForAssets = true
            
            if let upToDateAccount = sharedDataController.accountCollection[account.address]?.value {
                account = upToDateAccount
                reload()
            }
        }
    }
}

extension ManageAssetListLocalDataController {
    private func deliverUpdatesForLoading() {
        let updates = makeUpdatesForLoading()
        publish(updates: updates)
    }
    
    private func makeUpdatesForLoading() -> Updates {
        var snapshot = Snapshot()
        appendSectionForAssetsLoading(into: &snapshot)
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionForAssetsLoading(into snapshot: inout Snapshot) {
        let items: [ManageAssetListItem] = [.assetLoading]
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }
}

extension ManageAssetListLocalDataController {
    private func makeUpdatesForNoContent() -> Updates {
        var snapshot = Snapshot()
        appendSectionForNoContent(into: &snapshot)
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionForNoContent(into snapshot: inout Snapshot) {
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty(.noContent)],
            toSection: .empty
        )
    }
    
    private func makeUpdatesForSearchNoContent() -> Updates {
        var snapshot = Snapshot()
        appendSectionForSearchNoContent(into: &snapshot)
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionForSearchNoContent(into snapshot: inout Snapshot) {
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty(.noContentSearch)],
            toSection: .empty
        )
    }
}

extension ManageAssetListLocalDataController {
    private func deliverUpdatesForContent(
        when condition: () -> Bool,
        query: ManageAssetListQuery?
    ) {
        let updates = makeUpdatesForContent(query: query)
        
        if !condition() { return }
        
        self.lastQuery = query
        self.nextQuery = nil
        
        self.publish(updates: updates)
    }
    
    private func makeUpdatesForContent(
        query: ManageAssetListQuery?
    ) -> Updates {
        let assetlistItems = makeAssetListItems(query)
        
        let shouldShowEmptyContent = assetlistItems.isEmpty
        
        if shouldShowEmptyContent {
            let isSearching = !(query?.keyword.isNilOrEmpty ?? true)
            return isSearching ? makeUpdatesForSearchNoContent() : makeUpdatesForNoContent()
        }
        
        var snapshot = Snapshot()
        
        appendSectionsForContent(
            query: query,
            items: assetlistItems,
            into: &snapshot
        )
        
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionsForContent(
        query: ManageAssetListQuery?,
        items: [ManageAssetListItem],
        into snapshot: inout Snapshot
    ) {
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }
    
    private func makeAssetListItems(
        _ query: ManageAssetListQuery?
    ) -> [ManageAssetListItem] {
        let assets = account.allAssets
        
        let assetItems: [ManageAssetListItem] = assets.someArray.compactMap {
            asset in
            
            if let query,
               !query.matches(
                asset: asset,
                account: account
               ) {
                return nil
            }
            
            return makeItemForAsset(asset)
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
    
    private func makeItemForAsset(_ asset: Asset) -> ManageAssetListItem? {
        switch asset {
        case let nonNFTasset as StandardAsset: return makeStandardAssetItem(nonNFTasset)
        case let nftAsset as CollectibleAsset: return makeCollectibleAssetItem(nftAsset)
        default: return nil
        }
    }
    
    private func makeCollectibleAssetItem(_ asset: CollectibleAsset) -> ManageAssetListItem {
        let item = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let listItem = OptOutCollectibleAssetListItem(item: item)
        return .collectibleAsset(listItem)
    }
    
    private func makeStandardAssetItem(_ asset: StandardAsset) -> ManageAssetListItem {
        let currency = sharedDataController.currency
        let currencyFormatter = currencyFormatter
        let item = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let listItem = OptOutAssetListItem(item: item)
        return .asset(listItem)
    }
}

extension ManageAssetListLocalDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }
    
    private func publish(event: ManageAssetListDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }

            self.eventHandler?(event)
        }
    }
}

extension ManageAssetListLocalDataController {
    func hasOptedOut(_ asset: Asset) -> OptOutStatus {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptedOut = monitor.hasPendingOptOutRequest(
            assetID: asset.id,
            for: account
        )
        let hasAlreadyOptedOut = account[asset.id] == nil

        switch (hasPendingOptedOut, hasAlreadyOptedOut) {
        case (true, false): return .pending
        case (true, true): return .optedOut
        case (false, true): return .optedOut
        case (false, false): return .rejected
        }
    }
}

extension ManageAssetListLocalDataController {
    private func createAsyncLoadingQueue() -> AsyncSerialQueue {
        let underlyingQueue = DispatchQueue(
            label: "pera.queue.manageAsset.updates",
            qos: .userInitiated
        )
        return .init(
            name: "manageAssetListDataController.asyncLoadingQueue",
            underlyingQueue: underlyingQueue
        )
    }
    
    private func createCollectibleAmountFormatter() -> CollectibleAmountFormatter {
        return .init()
    }
    
    private func createCurrencyFormatter() -> CurrencyFormatter {
        return .init()
    }
    
    private func createSearchThrottler() -> Throttler {
        return .init(intervalInSeconds: 0.4)
    }
}

extension ManageAssetListLocalDataController {
    typealias Updates = ManageAssetListUpdates
    typealias Snapshot = ManageAssetListUpdates.Snapshot
}
