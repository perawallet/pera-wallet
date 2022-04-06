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
//   AssetSearchLocalDataController.swift

import Foundation
import MacaroonUtils

final class AssetSearchLocalDataController:
    AssetSearchDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AssetSearchDataControllerEvent) -> Void)?

    private var accountHandle: AccountHandle
    private var lastSnapshot: Snapshot?

    private var searchResults: [StandardAsset] = []

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.assetSearchDataController")

    init(
        accountHandle: AccountHandle,
        sharedDataController: SharedDataController
    ) {
        self.accountHandle = accountHandle
        self.sharedDataController = sharedDataController
        self.searchResults = accountHandle.value.standardAssets
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript (index: Int) -> StandardAsset? {
        return searchResults[safe: index]
    }
}

extension AssetSearchLocalDataController {
    func load() {
        sharedDataController.add(self)
    }

    func search(for query: String) {
        searchResults = accountHandle.value.standardAssets.filter { asset in
            isAssetContainsID(asset, query: query) ||
            isAssetContainsName(asset, query: query) ||
            isAssetContainsUnitName(asset, query: query)
        }

        deliverContentSnapshot()
    }

    func resetSearch() {
        searchResults = accountHandle.value.standardAssets
        deliverContentSnapshot()
    }

    private func isAssetContainsID(_ asset: StandardAsset, query: String) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: StandardAsset, query: String) -> Bool {
        return asset.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: StandardAsset, query: String) -> Bool {
        return asset.unitName.someString.localizedCaseInsensitiveContains(query)
    }
}

extension AssetSearchLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case let .didStartRunning(first):
            if first ||
                lastSnapshot == nil {
                deliverContentSnapshot()
            }
        case .didFinishRunning:
            if let updatedAccountHandle = sharedDataController.accountCollection[accountHandle.value.address] {
                accountHandle = updatedAccountHandle
            }
            deliverContentSnapshot()
        default:
            break
        }
    }
}

extension AssetSearchLocalDataController {
    private func deliverContentSnapshot() {
        guard !accountHandle.value.standardAssets.isEmpty else {
            deliverNoContentSnapshot()
            return
        }

        if searchResults.isEmpty {
            deliverEmptyContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            var assetItems: [AssetSearchItem] = []
            let currency = self.sharedDataController.currency.value

            self.searchResults.forEach {
                let assetPreview = AssetPreviewModelAdapter.adaptAssetSelection(($0, currency))
                let assetItem: AssetSearchItem = .asset(AssetPreviewViewModel(assetPreview))
                assetItems.append(assetItem)
            }

            snapshot.appendSections([.assets])

            let headerItem: AssetSearchItem = .header(
                AssetSearchListHeaderViewModel("accounts-title-assets".localized)
            )

            snapshot.appendItems(
                [headerItem],
                toSection: .assets
            )

            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()

            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [ .empty(AssetListSearchNoContentViewModel(hasBody: false)) ],
                toSection: .empty
            )

            return snapshot
        }
    }

    private func deliverEmptyContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()

            snapshot.appendSections([.empty])


            snapshot.appendItems(
                [ .empty(AssetListSearchNoContentViewModel(hasBody: true)) ],
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

            let newSnapshot = snapshot()

            self.lastSnapshot = newSnapshot
            self.publish(.didUpdate(newSnapshot))
        }
    }
}

extension AssetSearchLocalDataController {
    private func publish(
        _ event: AssetSearchDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
