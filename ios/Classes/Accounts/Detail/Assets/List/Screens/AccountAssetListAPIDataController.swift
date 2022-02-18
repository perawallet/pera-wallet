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

    private var accountHandle: AccountHandle
    private var assets: [AssetInformation] = []

    var addedAssetDetails: [AssetInformation] = []
    var removedAssetDetails: [AssetInformation] = []

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.accountAssetListDataController")

    init(
        _ accountHandle: AccountHandle,
        _ sharedDataController: SharedDataController
    ) {
        self.accountHandle = accountHandle
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension AccountAssetListAPIDataController {
    func load() {
        sharedDataController.add(self)
    }
}

extension AccountAssetListAPIDataController {
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

extension AccountAssetListAPIDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            let portfolio = AccountPortfolio(
                account: self.accountHandle,
                currency: self.sharedDataController.currency,
                calculator: ALGPortfolioCalculator()
            )
            let portfolioItem = AccountPortfolioViewModel(portfolio)

            snapshot.appendSections([.portfolio])
            snapshot.appendItems(
                [.portfolio(portfolioItem)],
                toSection: .portfolio
            )

            var assets: [AssetInformation] = []
            var assetItems: [AccountAssetsItem] = []

            assetItems.append(.search)

            let currency = self.sharedDataController.currency.value

            assetItems.append(.asset(AssetPreviewViewModel(AssetPreviewModelAdapter.adapt((self.accountHandle.value, currency)))))

            self.accountHandle.value.compoundAssets.forEach {
                assets.append($0.detail)
                
                let assetPreview = AssetPreviewModelAdapter.adaptAssetSelection(($0.detail, $0.base, currency))
                let assetItem: AccountAssetsItem = .asset(AssetPreviewViewModel(assetPreview))
                assetItems.append(assetItem)
            }

            self.clearAddedAssetDetailsIfNeeded(for: self.accountHandle.value)
            self.clearRemovedAssetDetailsIfNeeded(for: self.accountHandle.value)

            self.addedAssetDetails.forEach {
                let assetItem: AccountAssetsItem = .pendingAsset(PendingAssetPreviewViewModel(AssetPreviewModelAdapter.adaptPendingAsset($0)))
                assetItems.append(assetItem)
            }

            self.removedAssetDetails.forEach {
                let assetItem: AccountAssetsItem = .pendingAsset(PendingAssetPreviewViewModel(AssetPreviewModelAdapter.adaptPendingAsset($0)))
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

extension AccountAssetListAPIDataController {
    private func publish(
        _ event: AccountAssetListDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }

    private func clearAddedAssetDetailsIfNeeded(for account: Account) {
        addedAssetDetails = addedAssetDetails.filter { !account.contains($0) }
    }

    private func clearRemovedAssetDetailsIfNeeded(for account: Account) {
        removedAssetDetails = removedAssetDetails.filter { account.contains($0) }
    }
}
