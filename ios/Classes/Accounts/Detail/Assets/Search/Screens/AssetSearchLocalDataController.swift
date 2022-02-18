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

    private var searchResults: [CompoundAsset] = []

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.assetSearchDataController")

    init(
        _ accountHandle: AccountHandle,
        _ sharedDataController: SharedDataController
    ) {
        self.accountHandle = accountHandle
        self.sharedDataController = sharedDataController
        self.searchResults = accountHandle.value.compoundAssets
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript (index: Int) -> CompoundAsset? {
        return searchResults[safe: index]
    }

    func hasSection() -> Bool {
        return !searchResults.isEmpty
    }
}

extension AssetSearchLocalDataController {
    func load() {
        sharedDataController.add(self)
    }

    func search(for query: String) {
        searchResults = accountHandle.value.compoundAssets.filter {
            String($0.id).contains(query) ||
            $0.detail.name.unwrap(or: "").contains(query) ||
            $0.detail.unitName.unwrap(or: "").contains(query)
        }

        deliverContentSnapshot()
    }

    func resetSearch() {
        searchResults = accountHandle.value.compoundAssets
        deliverContentSnapshot()
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
        guard !accountHandle.value.compoundAssets.isEmpty else {
            deliverNoContentSnapshot()
            return
        }

        guard !searchResults.isEmpty else {
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
                let assetPreview = AssetPreviewModelAdapter.adaptAssetSelection(($0.detail, $0.base, currency))
                let assetItem: AssetSearchItem = .asset(AssetPreviewViewModel(assetPreview))
                assetItems.append(assetItem)
            }

            snapshot.appendSections([.assets])
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
                [.noContent],
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
                [.empty],
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
