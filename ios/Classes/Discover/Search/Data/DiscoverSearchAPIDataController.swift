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

//   DiscoverSearchAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class DiscoverSearchAPIDataController:
    DiscoverSearchDataController {
    var eventHandler: EventHandler?

    private lazy var apiThrottler = Throttler(intervalInSeconds: 0.4)
    private lazy var currencyFormatter = CurrencyFormatter()

    private var draft: SearchAssetsForDiscoverDraft?
    private var assetModelsCache: [AssetID: AssetDecoration] = [:]
    private var assetViewModelsCache: [AssetID: DiscoverSearchAssetListItemViewModel] = [:]

    private var trendingAssets: [AssetDecoration.APIModel]?

    private var snapshot: Snapshot?

    private var ongoingEndpointToGetAssets: EndpointOperatable?

    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    private let updatesQueue = DispatchQueue(
        label: "pera.queue.discover.search.updates",
        qos: .userInitiated
    )

    subscript(assetID: AssetID) -> AssetDecoration? {
        findModel(forID: assetID)
    }

    subscript(assetID: AssetID) -> DiscoverSearchAssetListItemViewModel? {
        findViewModel(forID: assetID)
    }

    init(
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
    }

    deinit {
        apiThrottler.cancelAll()
    }
}

extension DiscoverSearchAPIDataController {
    func loadListData(query: DiscoverSearchQuery?) {
        cancelLoadingListData()
        clearCache()
        deliverUpdatesForLoading()
        apply(query: query)

        if let draft = draft {
            loadListData(draft: draft)
        } else {
            loadInitialData()
        }
    }

    private func loadListData(draft: SearchAssetsForDiscoverDraft) {
        apiThrottler.performNext {
            [weak self] in
            guard let self else { return }

            self.getAssets(draft: draft) {
                [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let changes):
                    self.deliverUpdatesForAssets(changes)
                case .failure(let error):
                    self.deliverUpdatesForError(error)
                }
            }
        }
    }

    private func loadInitialData() {
        apiThrottler.cancelAll()

        getTrendingAssets {
            [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let trendingAssets):
                self.deliverUpdatesForTrendingAssets(trendingAssets)
            case .failure(let error):
                self.deliverUpdatesForError(error)
            }
        }
    }

    func loadNextListData() {
        if hasListDataBeingLoaded() { return }
        if !hasNextListDataToBeLoaded() { return }

        if let snapshot = snapshot,
           snapshot.sectionIdentifiers.last == .nextList,
           snapshot.itemIdentifiers(inSection: .nextList).first != .nextLoading {
            deliverUpdatesForNextLoading()
        }

        getAssets(draft: draft ?? .init()) {
            [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let changes):
                self.deliverUpdatesForNextAssets(changes)
            case .failure(let error):
                self.deliverUpdatesForNextError(error)
            }
        }
    }

    func hasListDataBeingLoaded() -> Bool {
        return !ongoingEndpointToGetAssets.isNilOrFinished
    }

    func hasNextListDataToBeLoaded() -> Bool {
        return draft?.cursor != nil
    }

    func cancelLoadingListData() {
        cancelGettingAssets()
    }
}

extension DiscoverSearchAPIDataController {
    private func apply(query: DiscoverSearchQuery?) {
        guard let keyword = (query?.keyword).unwrapNonEmptyString() else {
            draft = nil
            return
        }

        var newDraft = SearchAssetsForDiscoverDraft()
        newDraft.query = keyword
        newDraft.cursor = nil
        draft = newDraft
    }
}

extension DiscoverSearchAPIDataController {
    private typealias GetAssetsChanges = (assets: [AssetDecoration], hasNextAssets: Bool)
    private typealias GetAssetsError = HIPNetworkError<NoAPIModel>
    private typealias GetAssetsCompletion = (Result<GetAssetsChanges, GetAssetsError>) -> Void
    private func getAssets(
        draft: SearchAssetsForDiscoverDraft,
        completion: @escaping GetAssetsCompletion
    ) {
        ongoingEndpointToGetAssets = api.searchAssetsForDiscover(draft: draft) {
            [weak self] result in
            guard let self else { return  }

            self.ongoingEndpointToGetAssets = nil

            switch result {
            case .success(let list):
                self.draft?.cursor = list.nextCursor

                let changes = (list.results, !list.nextCursor.isNilOrEmpty)
                completion(.success(changes))
            case .failure(let apiError, let apiErrorDetail):
                let error = GetAssetsError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                completion(.failure(error))
            }
        }
    }

    private typealias GetTrendingAssetsCompletion = (Result<[AssetDecoration.APIModel], GetAssetsError>) -> Void
    private func getTrendingAssets(completion: @escaping GetTrendingAssetsCompletion) {
        if !trendingAssets.isNilOrEmpty {
            completion(.success(trendingAssets.someArray))
            return
        }

        ongoingEndpointToGetAssets = api.getTrendingAssets {
            [weak self] result in
            guard let self else { return  }

            self.ongoingEndpointToGetAssets = nil

            switch result {
            case .success(let results):
                self.trendingAssets = results
                completion(.success(results))
            case .failure(let apiError, let apiErrorDetail):
                let error = GetAssetsError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                completion(.failure(error))
            }
        }
    }

    private func cancelGettingAssets() {
        ongoingEndpointToGetAssets?.cancel()
        ongoingEndpointToGetAssets = nil
    }
}

extension DiscoverSearchAPIDataController {
    private func findModel(forID id: AssetID) -> AssetDecoration? {
        return assetModelsCache[id]
    }

    private func findViewModel(forID id: AssetID) -> DiscoverSearchAssetListItemViewModel? {
        if let cachedViewModel = assetViewModelsCache[id] {
            return cachedViewModel
        } else {
            let asset = findModel(forID: id)
            return asset.unwrap {
                return DiscoverSearchAssetListItemViewModel(
                    asset: $0,
                    currency: sharedDataController.currency,
                    currencyFormatter: currencyFormatter
                )
            }
        }
    }

    private func saveToCache(_ asset: AssetDecoration) {
        assetModelsCache[asset.id] = asset
        assetViewModelsCache[asset.id] = DiscoverSearchAssetListItemViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }

    private func clearCache() {
        assetModelsCache = [:]
        assetViewModelsCache = [:]
    }
}

extension DiscoverSearchAPIDataController {
    private func deliverUpdatesForLoading() {
        if let snapshot = snapshot,
           snapshot.sectionIdentifiers.first == .noContent,
           snapshot.itemIdentifiers(inSection: .noContent).first == .loading {
            return
        }

        deliverUpdatesByReloading() {
            var snapshot = Snapshot()
            snapshot.appendSections([.noContent])
            snapshot.appendItems(
                [.loading],
                toSection: .noContent
            )
            return snapshot
        }
    }

    private func deliverUpdatesForNotFound() {
        deliverUpdatesByReloading() {
            var snapshot = Snapshot()
            snapshot.appendSections([.noContent])
            snapshot.appendItems(
                [.notFound],
                toSection: .noContent
            )
            return snapshot
        }
    }

    private func deliverUpdatesForError(_ error: GetAssetsError) {
        deliverUpdatesByReloading() { [weak self] in
            guard let self else { return nil }

            var snapshot = Snapshot()
            snapshot.appendSections([.noContent])
            snapshot.appendItems(
                self.createErrorListItems(error: error),
                toSection: .noContent
            )
            return snapshot
        }
    }

    private func deliverUpdatesForAssets(_ changes: GetAssetsChanges) {
        if changes.assets.isEmpty {
            deliverUpdatesForNotFound()
            return
        }

        deliverUpdatesByReloading() { [weak self] in
            guard let self else { return nil }

            var snapshot = Snapshot()

            snapshot.appendSections([ .list ])
            snapshot.appendItems(
                self.createAssetListItems(assets: changes.assets),
                toSection: .list
            )

            if changes.hasNextAssets {
                snapshot.appendSections([ .nextList ])
                snapshot.appendItems(
                    [ .nextLoading ],
                    toSection: .nextList
                )
            }

            return snapshot
        }
    }

    private func deliverUpdatesForNextAssets(_ changes: GetAssetsChanges) {
        deliverUpdates() { [weak self] in
            guard let self else { return nil }
            guard var snapshot = self.snapshot else { return nil }

            snapshot.appendItems(
                self.createAssetListItems(assets: changes.assets),
                toSection: .list
            )

            if !changes.hasNextAssets {
                snapshot.deleteSections([ .nextList ])
            }

            return snapshot
        }
    }

    private func deliverUpdatesForNextLoading() {
        deliverUpdates() { [weak self] in
            guard let self else { return nil }
            guard var snapshot = self.snapshot else { return nil }

            snapshot.deleteSections([ .nextList ])

            snapshot.appendSections([ .nextList ])
            snapshot.appendItems(
                [ .nextLoading ],
                toSection: .nextList
            )

            return snapshot
        }
    }

    private func deliverUpdatesForNextError(_ error: GetAssetsError) {
        deliverUpdates() { [weak self] in
            guard let self else { return nil }
            guard var snapshot = self.snapshot else { return nil }

            snapshot.deleteSections([ .nextList ])

            snapshot.appendSections([ .nextList ])
            snapshot.appendItems(
                self.createNextErrorListItems(error: error),
                toSection: .nextList
            )

            return snapshot
        }
    }

    private func deliverUpdatesForTrendingAssets(_ assets: [AssetDecoration.APIModel]) {
        deliverUpdatesByReloading() { [weak self] in
            guard let self else { return nil }

            var listItems: [DiscoverSearchListItem] = []
            assets.forEach { asset in
                let theAsset = AssetDecoration(asset)
                let item = self.createAssetListItem(asset: theAsset)
                listItems.append(item)
            }

            var snapshot = Snapshot()
            snapshot.appendSections([ .list ])
            snapshot.appendItems(
                listItems,
                toSection: .list
            )
            return snapshot
        }
    }

    private func deliverUpdates(_ snapshot: @escaping () -> Snapshot?) {
        updatesQueue.async {
            [weak self] in
            guard let self = self else { return }
            guard let newSnapshot = snapshot() else { return }

            self.snapshot = newSnapshot
            self.publish(.didUpdate(newSnapshot))
        }
    }

    private func deliverUpdatesByReloading(_ snapshot: @escaping () -> Snapshot?) {
        updatesQueue.async {
            [weak self] in
            guard let self = self else { return }
            guard let newSnapshot = snapshot() else { return }

            self.snapshot = newSnapshot
            self.publish(.didReload(newSnapshot))
        }
    }
}

extension DiscoverSearchAPIDataController {
    private func publish(
        _ event: DiscoverSearchDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }
}

extension DiscoverSearchAPIDataController {
    private func createAssetListItems(
        assets: [AssetDecoration],
        saveToCache: Bool = true
    ) -> [DiscoverSearchListItem] {
        var listItems: [DiscoverSearchListItem] = []
        assets.forEach { asset in
            let item = createAssetListItem(
                asset: asset,
                saveToCache: saveToCache
            )
            listItems.append(item)
        }
        return listItems
    }

    private func createAssetListItem(
        asset: AssetDecoration,
        saveToCache: Bool = true
    ) -> DiscoverSearchListItem {
        if saveToCache {
            self.saveToCache(asset)
        }

        let assetItem = DiscoverSearchAssetListItem(assetID: asset.id)
        return .asset(assetItem)
    }

    private func createErrorListItems(error: GetAssetsError) -> [DiscoverSearchListItem] {
        let errorItem = createErrorItem(error: error)
        return [ .error(errorItem) ]
    }

    private func createNextErrorListItems(error: GetAssetsError) -> [DiscoverSearchListItem] {
        let errorItem = createErrorItem(error: error)
        return [ .nextError(errorItem) ]
    }

    private func createErrorItem(error: GetAssetsError) -> DiscoverSearchErrorItem {
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

        return DiscoverSearchErrorItem(title: title, body: body)
    }
}
