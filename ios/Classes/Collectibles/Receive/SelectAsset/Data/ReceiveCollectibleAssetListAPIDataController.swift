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

//   ReceiveCollectibleAssetListAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class ReceiveCollectibleAssetListAPIDataController:
    ReceiveCollectibleAssetListDataController {
    var eventHandler: ((ReceiveCollectibleAssetListDataControllerEvent) -> Void)?

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)
    private var ongoingEndpoint: EndpointOperatable?

    private var assets: [AssetDecoration] = []

    private var lastSnapshot: Snapshot?

    private let api: ALGAPI
    private let snapshotQueue = DispatchQueue(
        label: "com.algorand.queue.receiveCollectibleAssetListAPIDataController"
    )

    private var nextCursor: String?

    private var hasNext: Bool {
        return nextCursor != nil
    }

    init(_ api: ALGAPI) {
        self.api = api
    }

    subscript(index: Int) -> AssetDecoration? {
        return assets[safe: index]
    }
}

extension ReceiveCollectibleAssetListAPIDataController {
    func load() {
        deliverLoadingSnapshot()

        load(with: nil)
    }

    func search(for query: String?) {
        searchThrottler.performNext {
            [weak self] in

            guard let self = self else {
                return
            }

            self.resetSearch()

            self.load(with: query)
        }
    }

    func resetSearch() {
        nextCursor = nil
    }

    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        guard indexPath.item == assets.count - 3,
              hasNext else {
                  return
              }

        load(with: nil, isPaginated: true)
    }

    private func load(with query: String?, isPaginated: Bool = false) {
        cancelOngoingEndpoint()

        let searchDraft = AssetSearchQuery(
            status: .all,
            query: query,
            cursor: nextCursor,
            type: .collectible
        )

        ongoingEndpoint =
        api.searchAssets(
            searchDraft,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            switch response {
            case let .success(searchResults):
                guard let self = self else {
                    return
                }

                if isPaginated {
                    let results = self.assets + searchResults.results
                    self.assets = results.uniqued()
                } else {
                    self.assets = searchResults.results.uniqued()
                }

                self.deliverContentSnapshot()
                self.nextCursor = searchResults.nextCursor
            case .failure:
                /// <todo> Handle failure case.
                break
            }
        }
    }
    
    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension ReceiveCollectibleAssetListAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [.empty(.loading("1")), .empty(.loading("2"))],
                toSection: .loading
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        if assets.isEmpty {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var assetItems: [ReceiveCollectibleAssetListItem] = []

            var snapshot = Snapshot()

            snapshot.appendSections([.info, .search, .collectibles])

            for asset in self.assets {
                let collectibleAsset = CollectibleAsset(asset: ALGAsset(id: asset.id), decoration: asset)
                let assetItem: ReceiveCollectibleAssetListItem = .collectible(
                    AssetPreviewViewModel(collectibleAsset)
                )

                assetItems.append(assetItem)
            }

            if !self.assets.isEmpty {
                snapshot.appendItems(
                    [.info],
                    toSection: .info
                )

                snapshot.appendItems(
                    [.search],
                    toSection: .search
                )

                snapshot.appendItems(
                    assetItems,
                    toSection: .collectibles
                )
            }

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.info, .search, .empty])

            snapshot.appendItems(
                [.info],
                toSection: .info
            )

            snapshot.appendItems(
                [.search],
                toSection: .search
            )

            snapshot.appendItems(
                [.empty(.noContent)],
                toSection: .empty
            )
            return snapshot
        }
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

extension ReceiveCollectibleAssetListAPIDataController {
    private func publish(
        _ event: ReceiveCollectibleAssetListDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
