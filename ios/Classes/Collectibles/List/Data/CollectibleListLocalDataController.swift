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

//   CollectibleListLocalDataController.swift

import Foundation
import CoreGraphics
import MacaroonUtils

final class CollectibleListLocalDataController:
    CollectibleListDataController,
    SharedDataControllerObserver,
    NotificationObserver {
    static var didAddPendingCollectible: Notification.Name {
        return .init(rawValue: "com.algorand.didAddPendingCollectible")
    }

    static var assetUserInfoKey: String {
        return "collectibleListLocalDataController.userInfoKey.asset"
    }

    var notificationObservations: [NSObjectProtocol] = []

    var eventHandler: ((CollectibleDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.collectibleListDataController")

    private let galleryAccount: CollectibleGalleryAccount

    private var accounts: [Account]
    private let sharedDataController: SharedDataController

    typealias AccountAssetPair = (account: Account, asset: CollectibleAsset)
    private var pendingAccountAssetPairs: [AccountAssetPair] = []

    private let isWatchAccount: Bool

    var imageSize: CGSize = .zero

    private var lastQuery: String?

    init(
        galleryAccount: CollectibleGalleryAccount,
        sharedDataController: SharedDataController
    ) {
        self.galleryAccount = galleryAccount

        switch galleryAccount {
        case .single(let account):
            accounts = [account.value]
        case .all:
            accounts = sharedDataController.accountCollection.sorted().map(\.value)
        }

        self.sharedDataController = sharedDataController

        isWatchAccount = galleryAccount.singleAccount?.value.isWatchAccount() ?? false

        observe(notification: Self.didAddPendingCollectible) {
            [weak self] notification in
            guard let self = self else { return }

            if let accountAssetPair =
                notification.userInfo?[
                    Self.assetUserInfoKey
                ] as? AccountAssetPair {

                self.addPendingAccountAssetPair(
                    accountAssetPair
                )
            }
        }
    }

    deinit {
        sharedDataController.remove(self)
        unobserveNotifications()
    }
}

extension CollectibleListLocalDataController {
    func load() {
        sharedDataController.add(self)
    }

    func search(for query: String) {
        lastQuery = query

        deliverContentSnapshot(with: query)
    }

    func resetSearch() {
        lastQuery = nil
        deliverContentSnapshot()
    }
}

extension CollectibleListLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialSnapshot()
        case .didStartRunning(let isFirst):
            if isFirst ||
               lastSnapshot == nil {
                deliverInitialSnapshot()
            }
        case .didFinishRunning:
            switch galleryAccount {
            case .single(let account):
                if let updatedAccount = sharedDataController.accountCollection[account.value.address] {
                    accounts = [updatedAccount.value]

                    if let lastQuery = lastQuery {
                        search(for: lastQuery)
                    } else {
                        deliverContentSnapshot()
                    }
                }
            case .all:
                accounts = sharedDataController.accountCollection.sorted().map(\.value)

                if let lastQuery = lastQuery {
                    search(for: lastQuery)
                } else {
                    deliverContentSnapshot()
                }
            }
        }
    }
}

extension CollectibleListLocalDataController {
    private func deliverInitialSnapshot() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingSnapshot()
        } else {
            deliverNoContentSnapshot()
        }
    }

    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [.empty(.loading)],
                toSection: .loading
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot(
        with query: String? = nil
    ) {
        var collectibleItems: [CollectibleListItem] = []

        accounts.forEach { account in
            account
                .collectibleAssets
                .forEach { collectibleAsset in
                    if let query = query,
                       !isAssetContains(collectibleAsset, query: query) {
                        return
                    }

                    let cellItem: CollectibleItem

                    if collectibleAsset.isOwned {
                        cellItem = .cell(
                            .owner(
                                CollectibleCellItemContainer(
                                    account: account,
                                    asset: collectibleAsset,
                                    viewModel: CollectibleListItemReadyViewModel(
                                        imageSize: imageSize,
                                        model: collectibleAsset
                                    )
                                )
                            )
                        )
                    } else {
                        cellItem = .cell(
                            .optedIn(
                                CollectibleCellItemContainer(
                                    account: account,
                                    asset: collectibleAsset,
                                    viewModel: CollectibleListItemReadyViewModel(
                                        imageSize: imageSize,
                                        model: collectibleAsset
                                    )
                                )
                            )
                        )
                    }

                    let listItem: CollectibleListItem = .collectible(cellItem)
                    collectibleItems.append(listItem)
                }
        }

        if collectibleItems.isEmpty {
            if lastQuery != nil {
                deliverSearchNoContentSnapshot()
            } else {
                deliverNoContentSnapshot()
            }

            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()

            snapshot.appendSections([.search, .collectibles])

            snapshot.appendItems(
                [.search],
                toSection: .search
            )

            self.accounts.forEach { account in
                self.clearPendingAccountAssetPairsIfNeeded(
                    for: account
                )
            }

            var pendingCollectibleItems: [CollectibleListItem] = []

            self.pendingAccountAssetPairs.forEach { pendingAccountAssetPair in
                let cellItem: CollectibleItem = .cell(
                    .pending(
                        CollectibleCellItemContainer(
                            account: pendingAccountAssetPair.account,
                            asset: pendingAccountAssetPair.asset,
                            viewModel: CollectibleListItemPendingViewModel(
                                imageSize: self.imageSize,
                                model: pendingAccountAssetPair.asset
                            )
                        )
                    )
                )

                let listItem: CollectibleListItem = .collectible(cellItem)
                pendingCollectibleItems.append(listItem)
            }

            snapshot.appendItems(
                pendingCollectibleItems,
                toSection: .collectibles
            )
            
            snapshot.appendItems(
                collectibleItems,
                toSection: .collectibles
            )

            if !self.isWatchAccount {
                snapshot.appendItems(
                    [.collectible(.footer)],
                    toSection: .collectibles
                )
            }

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent)],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSearchNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.search, .empty])

            snapshot.appendItems(
                [.search],
                toSection: .search
            )

            snapshot.appendItems(
                [.empty(.noContentSearch)],
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

extension CollectibleListLocalDataController {
    private func addPendingAccountAssetPair(
        _ accountAssetPair: AccountAssetPair
    ) {
        accountAssetPair.asset.state = .pending(.add)
        pendingAccountAssetPairs.append(accountAssetPair)

        if let lastQuery = lastQuery {
            search(for: lastQuery)
        } else {
            deliverContentSnapshot()
        }
    }

    private func clearPendingAccountAssetPairsIfNeeded(
        for account: Account
    ) {
        pendingAccountAssetPairs = pendingAccountAssetPairs.filter {
            return !($0.account.address == account.address && account.containsCollectibleAsset($0.asset.id))
        }
    }
}

extension CollectibleListLocalDataController {
    private func publish(
        _ event: CollectibleDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

extension CollectibleListLocalDataController {
    private func isAssetContains(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return isAssetContainsTitle(asset, query: query) ||
        isAssetContainsID(asset, query: query) ||
        isAssetContainsName(asset, query: query) ||
        isAssetContainsUnitName(asset, query: query)
    }

    private func isAssetContainsTitle(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.title.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsID(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.unitName.someString.localizedCaseInsensitiveContains(query)
    }
}

extension CollectibleListLocalDataController {
    enum CollectibleGalleryAccount {
        case single(AccountHandle)
        case all

        var singleAccount: AccountHandle? {
            switch self {
            case .single(let account): return account
            default: return nil
            }
        }
    }
}
