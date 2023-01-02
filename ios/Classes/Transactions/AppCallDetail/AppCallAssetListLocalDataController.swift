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

//   AppCallAssetListLocalDataController.swift

import Foundation
import MacaroonUtils

final class AppCallAssetListLocalDataController:
    AppCallAssetListDataController {
    typealias EventHandler = (AppCallAssetListDataControllerEvent) -> Void

    var eventHandler: EventHandler?

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.appCallAssets.updates",
        qos: .userInitiated
    )

    private(set) var assets: [Asset]

    init(
        assets: [Asset]
    ) {
        self.assets = assets
    }
}

extension AppCallAssetListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension AppCallAssetListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            snapshot.appendSections([ .assets ])

            self.addAssetItems(&snapshot)

            return snapshot
        }
    }

    private func addAssetItems(
        _ snapshot: inout Snapshot
    ) {
        let assetItems =
        assets.map(makeAssetItem)

        snapshot.appendItems(
            assetItems,
            toSection: .assets
        )
    }

    private func makeAssetItem(
        _ asset: Asset
    ) -> AppCallAssetListItem {
        let viewModel = AppCallAssetPreviewWithImageViewModel(
            asset: asset
        )

        let item: AppCallAssetListItem = .cell(
            AppCallAssetListAssetPreviewWithImageContainer(
                viewModel: viewModel
            )
        )
        return item
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

extension AppCallAssetListLocalDataController {
    private func publish(
        _ event: AppCallAssetListDataControllerEvent
    ) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}
