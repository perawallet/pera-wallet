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
//   AssetListViewAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class AssetListViewAPIDataController:
    AssetListViewDataController,
    SharedDataControllerObserver {
    var eventHandler: EventHandler?

    private(set) var account: Account
    
    private lazy var asyncLoadingQueue = makeAsyncLoadingQueue()
    private lazy var searchThrottler = makeSearchThrottler()
        
    private var nextDraft: OptInAssetListDraft?
    private var lastDraft: OptInAssetListDraft?
    private var lastSnapshot: Snapshot?

    private var assetModelsCache: [AssetID: AssetDecoration] = [:]
    /// <todo>
    /// We can have some sort of UI cache and manage it outside of the scope of this type.
    private var assetViewModelsCache: [AssetID: OptInAssetListItemViewModel] = [:]

    private var ongoingEndpointToFetchAssets: EndpointOperatable?

    private var isFirstLoading = true
    
    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    subscript(assetID: AssetID) -> AssetDecoration? {
        return findModel(forID: assetID)
    }

    subscript(assetID: AssetID) -> OptInAssetListItemViewModel? {
        return findViewModel(forID: assetID)
    }

    init(
        account: Account,
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.api = api
        self.sharedDataController = sharedDataController
    }

    deinit {
        cancel()
        sharedDataController.remove(self)
    }
}

extension AssetListViewAPIDataController {
    func load(query: OptInAssetListQuery?) {
        let draft = OptInAssetListDraft(query: query)

        if draft == lastDraft {
            nextDraft = nil
            return
        }

        cancel()
        clearCache()
        loadData(draft: draft)
    }

    private func loadData(draft: OptInAssetListDraft) {
        nextDraft = draft

        deliverUpdatesForLoading()

        searchThrottler.performNext {
            [weak self] in
            guard let self else { return }

            self.fetchAssets(draft: draft) {
                [weak self] result in
                guard let self else { return }

                let task = self.makeTaskWithUpdatesForContent(
                    draft: draft,
                    result: result
                )
                self.enqueueNextUpdates(task)
            }
        }
    }

    func loadMore() {
        if hasMoreBeingLoaded() { return }
        if hasMoreFailedToBeLoaded() { return }
        loadMoreData()
    }

    func loadMoreAgain() {
        if hasMoreBeingLoaded() { return }
        loadMoreData()
    }

    private func loadMoreData() {
        guard let draft = lastDraft.unwrap(where: \.hasMore) else { return }

        nextDraft = draft

        let task = makeTaskWithUpdatesForLoadingMore()
        enqueueNextUpdates(task)

        fetchAssets(draft: draft) {
            [weak self] result in
            guard let self else { return }

            let task = self.makeTaskWithUpdatesForMoreContent(
                draft: draft,
                result: result
            )
            self.enqueueNextUpdates(task)
        }
    }

    private func hasMoreBeingLoaded() -> Bool {
        return !ongoingEndpointToFetchAssets.isNilOrFinished
    }

    private func hasMoreFailedToBeLoaded() -> Bool {
        return nextDraft != nil
    }

    func cancel() {
        /// <note>
        /// Cancel next search
        searchThrottler.cancelAll()

        /// <note>
        /// Cancel ongoing search
        cancelFetchingAssets()
        asyncLoadingQueue.cancel()

        lastDraft = nil
        nextDraft = nil
    }

    private func startObservingForAccountUpdates() {
        guard isFirstLoading else { return }
        sharedDataController.add(self)
        isFirstLoading = false
    }

    private typealias AssetListResult = Result<AssetDecorationList, AssetListError>
    private typealias AssetListError = HIPNetworkError<NoAPIModel>
    private func fetchAssets(
        draft: OptInAssetListDraft,
        completion: @escaping (AssetListResult) -> Void
    ) {
        var endpointDraft = AssetSearchQuery()
        endpointDraft.query = draft.query
        endpointDraft.cursor = draft.cursor

        ongoingEndpointToFetchAssets = api.searchAssets(
            endpointDraft,
            ignoreResponseOnCancelled: true
        ) { [weak self] result in
            guard let self else { return }

            self.ongoingEndpointToFetchAssets = nil

            switch result {
            case .success(let list):
                completion(.success(list))
            case .failure(let apiError, let apiErrorDetail):
                let err = AssetListError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                completion(.failure(err))
            }
        }
    }

    private func cancelFetchingAssets() {
        ongoingEndpointToFetchAssets?.cancel()
        ongoingEndpointToFetchAssets = nil
    }
}

extension AssetListViewAPIDataController {
    func hasOptedIn(_ asset: AssetDecoration) -> OptInStatus {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptedIn = monitor.hasPendingOptInRequest(
            assetID: asset.id,
            for: account
        )
        let hasAlreadyOptedIn = account[asset.id] != nil

        switch (hasPendingOptedIn, hasAlreadyOptedIn) {
        case (true, false): return .pending
        case (true, true): return .optedIn
        case (false, true): return .optedIn
        case (false, false): return .rejected
        }
    }
}

extension AssetListViewAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
            eventHandler?(.didUpdateAccount)
        }
    }

    private func updateAccountIfNeeded() {
        let updatedAccount = sharedDataController.accountCollection[account.address]

        guard let account = updatedAccount else { return }

        if !account.isAvailable { return }

        self.account = account.value
    }
}

extension AssetListViewAPIDataController {
    private func enqueueNextUpdates(_ task: AsyncTask) {
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }

    private func makeTaskWithUpdatesForContent(
        draft: OptInAssetListDraft,
        result: AssetListResult
    ) -> AsyncTask {
        return AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            switch result {
            case .success(let list):
                self.deliverUpdatesForContent(
                    list,
                    when: { draft == self.nextDraft },
                    success: { [weak self] in
                        guard let self else { return }

                        self.saveUpdatesForNewContent((draft, list))
                        self.startObservingForAccountUpdates()

                        completionBlock()
                    },
                    failure: {
                        completionBlock()
                    }
                )
            case .failure(let error):
                self.deliverUpdatesForLoadingFailed(error)
                completionBlock()
            }
        }
    }

    private func makeTaskWithUpdatesForLoadingMore() -> AsyncTask {
        return AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            self.deliverUpdatesForLoadingMore()
            completionBlock()
        }
    }

    private func makeTaskWithUpdatesForMoreContent(
        draft: OptInAssetListDraft,
        result: AssetListResult
    ) -> AsyncTask {
        return AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            switch result {
            case .success(let list):
                self.deliverUpdatesForMoreContent(
                    list,
                    when: { draft == self.nextDraft },
                    success: { [weak self] in
                        guard let self else { return }

                        self.saveUpdatesForNewContent((draft, list))
                        completionBlock()
                    },
                    failure: {
                        completionBlock()
                    }
                )
            case .failure(let error):
                self.deliverUpdatesForLoadingMoreFailed(error)
                completionBlock()
            }
        }
    }

    private typealias ContentUpdates = (draft: OptInAssetListDraft, list: AssetDecorationList)
    private func saveUpdatesForNewContent(_ updates: ContentUpdates) {
        self.lastDraft = updates.draft
        self.lastDraft?.cursor = updates.list.nextCursor
        self.nextDraft = nil
    }
}

extension AssetListViewAPIDataController {
    private func deliverUpdatesForLoading() {
        if lastSnapshot?.indexOfSection(.noContent) != nil,
           lastSnapshot?.itemIdentifiers(inSection: .noContent).last == .loading {
            return
        }
        
        var snapshot = Snapshot()
        appendSectionsForLoading(into: &snapshot)

        publishUpdatesByReloading(snapshot)
    }

    private func appendSectionsForLoading(into snapshot: inout Snapshot) {
        let items = makeItemsForLoading()
        snapshot.appendSections([ .noContent ])
        snapshot.appendItems(
            items,
            toSection: .noContent
        )
    }

    private func makeItemsForLoading() -> [ItemIdentifier] {
        return [ .loading ]
    }

    private func deliverUpdatesForLoadingFailed(_ error: AssetListError) {
        var snapshot = Snapshot()
        appendSectionsForLoadingFailed(
            error,
            into: &snapshot
        )

        publishUpdatesByReloading(snapshot)
    }

    private func appendSectionsForLoadingFailed(
        _ error: AssetListError,
        into snapshot: inout Snapshot
    ) {
        let items = makeItemsForLoadingFailed(error)
        snapshot.appendSections([ .noContent ])
        snapshot.appendItems(
            items,
            toSection: .noContent
        )
    }

    private func makeItemsForLoadingFailed(_ error: AssetListError) -> [ItemIdentifier] {
        let item = makeItem(for: error)
        return [ .loadingFailed(item) ]
    }

    private func makeItem(for error: AssetListError) -> OptInAssetList.ErrorItem {
        let fallbackTitle = "title-generic-api-error".localized
        let fallbackBody = "\("asset-search-not-found".localized)\n\("title-retry-later".localized)"

        let title: String
        let body: String
        switch error {
        case .connection(let connectionError):
            if connectionError.isNotConnectedToInternet {
                title = "discover-error-connection-title".localized
                body = "discover-error-connection-body".localized
            } else {
                title = fallbackTitle
                body = fallbackBody
            }
        default:
            title = fallbackTitle
            body = fallbackBody
        }

        return .init(title: title, body: body)
    }
    
    private func deliverUpdatesForContent(
        _ list: AssetDecorationList,
        when condition: () -> Bool,
        success: () -> Void,
        failure: () -> Void
    ) {
        if !condition() {
            failure()
            return
        }

        var snapshot = Snapshot()
        appendSectionsForContent(
            list,
            into: &snapshot
        )

        if !condition() {
            failure()
            return
        }

        publishUpdatesByReloading(snapshot)
        success()
    }

    private func appendSectionsForContent(
        _ list: AssetDecorationList,
        into snapshot: inout Snapshot
    ) {
        if list.results.isEmpty {
            appendSectionsForNotFound(into: &snapshot)
        } else {
            appendSectionsForAssets(
                list.results,
                into: &snapshot
            )

            if list.hasMore {
                appendSectionsForLoadingMore(into: &snapshot)
            }
        }
    }

    private func appendSectionsForNotFound(into snapshot: inout Snapshot) {
        let items = makeItemsForNotFound()
        snapshot.appendSections([ .noContent ])
        snapshot.appendItems(
            items,
            toSection: .noContent
        )
    }

    private func makeItemsForNotFound() -> [ItemIdentifier] {
        return [ .notFound ]
    }

    private func appendSectionsForAssets(
        _ assets: [AssetDecoration],
        into snapshot: inout Snapshot
    ) {
        let items = makeItemsForAssets(assets)
        snapshot.appendSections([ .content ])
        snapshot.appendItems(
            items,
            toSection: .content
        )
    }

    private func makeItemsForAssets(_ assets: [AssetDecoration]) -> [ItemIdentifier] {
        return assets.map { .asset(makeItem(for: $0)) }
    }

    private func makeItem(for asset: AssetDecoration) -> OptInAssetList.AssetItem {
        saveToCache(asset)
        return .init(assetID: asset.id)
    }

    private func deliverUpdatesForLoadingMore() {
        guard var snapshot = lastSnapshot else { return }

        if snapshot.indexOfSection(.waitingForMore) != nil,
           snapshot.itemIdentifiers(inSection: .waitingForMore).last == .loadingMore {
            return
        }

        /// <note>
        /// If the last snapshot contains the `loadingMoreFailed` item identifier, the section
        /// should be removed first to not deal with the items in the section.
        removeSectionsForLoadingMore(from: &snapshot)
        appendSectionsForLoadingMore(into: &snapshot)

        publishUpdates(snapshot)
    }

    private func removeSectionsForLoadingMore(from snapshot: inout Snapshot) {
        guard snapshot.indexOfSection(.waitingForMore) != nil else { return }
        snapshot.deleteSections([ .waitingForMore ])
    }

    private func appendSectionsForLoadingMore(into snapshot: inout Snapshot) {
        let items = makeItemsForLoadingMore()
        snapshot.appendSections([ .waitingForMore ])
        snapshot.appendItems(
            items,
            toSection: .waitingForMore
        )
    }

    private func makeItemsForLoadingMore() -> [ItemIdentifier] {
        return [ .loadingMore ]
    }

    private func deliverUpdatesForMoreContent(
        _ list: AssetDecorationList,
        when condition: () -> Bool,
        success: () -> Void,
        failure: () -> Void
    ) {
        if !condition() {
            failure()
            return
        }

        guard var snapshot = lastSnapshot else {
            failure()
            return
        }

        appendSectionsForMoreContent(
            list,
            into: &snapshot
        )

        if !condition() {
            failure()
            return
        }

        publishUpdates(snapshot)
        success()
    }

    private func appendSectionsForMoreContent(
        _ list: AssetDecorationList,
        into snapshot: inout Snapshot
    ) {
        let items = makeItemsForAssets(list.results)
        snapshot.appendItems(
            items,
            toSection: .content
        )

        if !list.hasMore {
            removeSectionsForLoadingMore(from: &snapshot)
        }
    }
    
    private func deliverUpdatesForLoadingMoreFailed(_ error: AssetListError) {
        guard var snapshot = lastSnapshot else { return }

        /// <note>
        /// If the last snapshot contains the `loadingMoreFailed` item identifier, the section
        /// should be removed first to not deal with the items in the section.
        removeSectionsForLoadingMore(from: &snapshot)
        appendSectionsForLoadingMoreFailed(
            error,
            into: &snapshot
        )

        publishUpdates(snapshot)
    }

    private func appendSectionsForLoadingMoreFailed(
        _ error: AssetListError,
        into snapshot: inout Snapshot
    ) {
        let items = makeItemsForLoadingMoreFailed(error)
        snapshot.appendSections([ .waitingForMore ])
        snapshot.appendItems(
            items,
            toSection: .waitingForMore
        )
    }

    private func makeItemsForLoadingMoreFailed(_ error: AssetListError) -> [ItemIdentifier] {
        let item = makeItem(for: error)
        return [ .loadingMoreFailed(item) ]
    }
}

extension AssetListViewAPIDataController {
    private func publishUpdates(_ snapshot: Snapshot?) {
        guard let snapshot else { return }

        lastSnapshot = snapshot
        publish(event: .didUpdate(snapshot))
    }

    private func publishUpdatesByReloading(_ snapshot: Snapshot?) {
        guard let snapshot else { return }

        lastSnapshot = snapshot
        publish(event: .didReload(snapshot))
    }

    private func publish(event: AssetListDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }
            self.eventHandler?(event)
        }
    }
}

extension AssetListViewAPIDataController {
    private func findModel(forID id: AssetID) -> AssetDecoration? {
        return assetModelsCache[id]
    }

    private func findViewModel(forID id: AssetID) -> OptInAssetListItemViewModel? {
        if let cachedViewModel = assetViewModelsCache[id] {
            return cachedViewModel
        } else {
            let asset = findModel(forID: id)
            return asset.unwrap(OptInAssetListItemViewModel.init)
        }
    }

    private func saveToCache(_ asset: AssetDecoration) {
        assetModelsCache[asset.id] = asset
        assetViewModelsCache[asset.id] = OptInAssetListItemViewModel(asset: asset)
    }

    private func clearCache() {
        assetModelsCache = [:]
        assetViewModelsCache = [:]
    }
}

extension AssetListViewAPIDataController {
    private func makeAsyncLoadingQueue() -> AsyncSerialQueue {
        let underlyingQueue = DispatchQueue(
            label: "pera.queue.assetAddition.updates",
            qos: .userInitiated
        )
        return .init(
            name: "assetListViewAPIDataController.asyncLoadingQueue",
            underlyingQueue: underlyingQueue
        )
    }

    private func makeSearchThrottler() -> Throttler {
        return .init(intervalInSeconds: 0.4)
    }
}
