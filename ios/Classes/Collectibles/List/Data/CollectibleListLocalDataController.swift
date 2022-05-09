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
    static var didAddCollectible: Notification.Name {
        return .init(rawValue: Constants.Notification.collectibleListDidAddCollectible)
    }

    static var didRemoveCollectible: Notification.Name {
        return .init(rawValue: Constants.Notification.collectibleListDidRemoveCollectible)
    }

    static var didSendCollectible: Notification.Name {
        return .init(rawValue: Constants.Notification.collectibleListDidSendCollectible)
    }

    static var accountAssetPairUserInfoKey: String {
        return Constants.Notification.InfoKey.collectibleListAccountAssetPair
    }

    var notificationObservations: [NSObjectProtocol] = []

    var eventHandler: ((CollectibleDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(
        label: Constants.DispatchQueues.collectibleListSnapshot
    )

    let galleryAccount: CollectibleGalleryAccount

    private var accounts: [Account]
    private let sharedDataController: SharedDataController

    typealias AccountAssetPair = (account: Account, asset: CollectibleAsset)
    private var addedAccountAssetPairs: [AccountAssetPair] = []
    private var removedAccountAssetPairs: [AccountAssetPair] = []
    private var sentAccountAssetPairs: [AccountAssetPair] = []

    private let isWatchAccount: Bool

    var imageSize: CGSize = .zero

    private var lastQuery: String?
    private(set) var currentFilter: CollectiblesFilterSelectionViewController.Filter = .owned
    private var hiddenCollectibleCount: Int = .zero

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

        observePendingAccountAssetPairs()
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

    func filter(
        by filter: CollectiblesFilterSelectionViewController.Filter
    ) {
        if filter == currentFilter {
            return
        }

        currentFilter = filter

        deliverContentSnapshot(with: lastQuery)
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
                guard let updatedAccount = sharedDataController.accountCollection[account.value.address] else {
                    return
                }

                if case .failed = updatedAccount.status {
                    if lastSnapshot == nil {
                        deliverInitialSnapshot()
                    }

                    eventHandler?(.didFinishRunning(hasError: true))
                    return
                }

                eventHandler?(.didFinishRunning(hasError: false))

                accounts = [updatedAccount.value]

                if let lastQuery = lastQuery {
                    search(for: lastQuery)
                } else {
                    deliverContentSnapshot()
                }
            case .all:
                let accounts = sharedDataController.accountCollection.sorted()

                for account in accounts {
                    if case .failed = account.status {
                        if lastSnapshot == nil {
                            deliverInitialSnapshot()
                        }

                        eventHandler?(.didFinishRunning(hasError: true))
                        return
                    }
                }

                eventHandler?(.didFinishRunning(hasError: false))

                self.accounts = accounts.map(\.value)

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
        hiddenCollectibleCount = .zero
        var collectibleItems: [CollectibleListItem] = []

        accounts.forEach { account in
            clearPendingAccountAssetPairsIfNeeded(
                for: account
            )

            account
                .collectibleAssets
                .forEach { collectibleAsset in
                    if currentFilter == .owned,
                       !collectibleAsset.isOwned {
                        hiddenCollectibleCount += 1
                        return
                    }

                    if let query = query,
                       !isAssetContains(collectibleAsset, query: query) {
                        return
                    }

                    let cellItem: CollectibleItem

                    if collectibleAsset.isOwned {
                        cellItem = .cell(
                            .owner(
                                CollectibleCellItemContainer(
                                    isPending: getPendingStatus(
                                        asset: collectibleAsset,
                                        account: account
                                    ),
                                    account: account,
                                    asset: collectibleAsset,
                                    viewModel: CollectibleListItemViewModel(
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
                                    isPending: getPendingStatus(
                                        asset: collectibleAsset,
                                        account: account
                                    ),
                                    account: account,
                                    asset: collectibleAsset,
                                    viewModel: CollectibleListItemViewModel(
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

        var pendingCollectibleItems: [CollectibleListItem] = []

        let pendingAccountAssetPairs =
        addedAccountAssetPairs +
        removedAccountAssetPairs +
        sentAccountAssetPairs

        pendingAccountAssetPairs.forEach { pendingAccountAssetPair in
            let pendingCollectibleAsset = pendingAccountAssetPair.asset
            let pendingCollectibleAccount = pendingAccountAssetPair.account

            let account = accounts.first(matching: (\.address, pendingCollectibleAccount.address))

            if let account = account,
               account.containsCollectibleAsset(pendingCollectibleAsset.id) {
                return
            }

            if let query = query,
               !isAssetContains(
                pendingCollectibleAsset,
                query: query
               ) {
                return
            }

            let cellItem: CollectibleItem = .cell(
                .pending(
                    CollectibleCellItemContainer(
                        isPending: true,
                        account: pendingCollectibleAccount,
                        asset: pendingCollectibleAsset,
                        viewModel: CollectibleListItemViewModel(
                            imageSize: imageSize,
                            model: pendingCollectibleAsset
                        )
                    )
                )
            )

            let listItem: CollectibleListItem = .collectible(cellItem)
            pendingCollectibleItems.append(listItem)
        }

        if collectibleItems.isEmpty &&
            pendingCollectibleItems.isEmpty {
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

            snapshot.appendSections([.search, .header, .collectibles])

            snapshot.appendItems(
                [
                    .header(
                        SelectionValue(
                            value: CollectibleListInfoWithFilterViewModel(
                                collectibleCount: collectibleItems.count
                            ),
                            isSelected: self.currentFilter == .all
                        )
                    )
                ],
                toSection: .header
            )

            snapshot.appendItems(
                [.search],
                toSection: .search
            )

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
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [
                    .empty(
                        .noContent(
                            CollectiblesNoContentWithActionViewModel(
                                hiddenCollectibleCount: self.hiddenCollectibleCount,
                                isWatchAccount: self.isWatchAccount
                            )
                        )
                    )
                ],
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
    private func observePendingAccountAssetPairs() {
        observe(notification: Self.didAddCollectible) {
            [weak self] notification in
            guard let self = self else { return }

            if let accountAssetPair =
                notification.userInfo?[
                    Self.accountAssetPairUserInfoKey
                ] as? AccountAssetPair {

                self.addAddedAccountAssetPair(
                    accountAssetPair
                )
            }
        }

        observe(notification: Self.didRemoveCollectible) {
            [weak self] notification in
            guard let self = self else { return }

            if let accountAssetPair =
                notification.userInfo?[
                    Self.accountAssetPairUserInfoKey
                ] as? AccountAssetPair {

                self.addRemovedAccountAssetPair(
                    accountAssetPair
                )
            }
        }

        observe(notification: Self.didSendCollectible) {
            [weak self] notification in
            guard let self = self else { return }

            if let accountAssetPair =
                notification.userInfo?[
                    Self.accountAssetPairUserInfoKey
                ] as? AccountAssetPair {

                self.addSentAccountAssetPair(
                    accountAssetPair
                )
            }
        }
    }

    private func addAddedAccountAssetPair(
        _ accountAssetPair: AccountAssetPair
    ) {
        let isAlreadyPending = addedAccountAssetPairs.contains { addedAccountAssetPair in
            addedAccountAssetPair.account.address == accountAssetPair.account.address &&
            addedAccountAssetPair.asset.id == accountAssetPair.asset.id
        }

        if isAlreadyPending {
            return
        }

        accountAssetPair.asset.state = .pending(.add)
        addedAccountAssetPairs.append(accountAssetPair)

        if let lastQuery = lastQuery {
            search(for: lastQuery)
        } else {
            deliverContentSnapshot()
        }
    }

    private func addRemovedAccountAssetPair(
        _ accountAssetPair: AccountAssetPair
    ) {
        let isAlreadyPending = removedAccountAssetPairs.contains { removedAccountAssetPair in
            removedAccountAssetPair.account.address == accountAssetPair.account.address &&
            removedAccountAssetPair.asset.id == accountAssetPair.asset.id
        }

        if isAlreadyPending {
            return
        }

        accountAssetPair.asset.state = .pending(.remove)
        removedAccountAssetPairs.append(accountAssetPair)

        if let lastQuery = lastQuery {
            search(for: lastQuery)
        } else {
            deliverContentSnapshot()
        }
    }

    private func addSentAccountAssetPair(
        _ accountAssetPair: AccountAssetPair
    ) {
        let isAlreadyPending = sentAccountAssetPairs.contains { sentAccountAssetPair in
            sentAccountAssetPair.account.address == accountAssetPair.account.address &&
            sentAccountAssetPair.asset.id == accountAssetPair.asset.id
        }

        if isAlreadyPending {
            return
        }

        accountAssetPair.asset.state = .pending(.remove)
        sentAccountAssetPairs.append(accountAssetPair)

        if let lastQuery = lastQuery {
            search(for: lastQuery)
        } else {
            deliverContentSnapshot()
        }
    }

    private func clearPendingAccountAssetPairsIfNeeded(
        for account: Account
    ) {
        clearAddedAccountAssetPairsIfNeeded(
            for: account
        )

        clearRemovedAccountAssetPairsIfNeeded(
            for: account
        )

        clearSentAccountAssetPairsIfNeeded(
            for: account
        )
    }

    private func clearAddedAccountAssetPairsIfNeeded(
        for account: Account
    ) {
        addedAccountAssetPairs = addedAccountAssetPairs.filter {
            pendingAddedAccountAssetPair in
            if account.address != pendingAddedAccountAssetPair.account.address {
                return true
            }

            return !account.containsCollectibleAsset(pendingAddedAccountAssetPair.asset.id)
        }
    }

    private func clearRemovedAccountAssetPairsIfNeeded(
        for account: Account
    ) {
        removedAccountAssetPairs = removedAccountAssetPairs.filter {
            pendingRemovedAccountAssetPair in
            if account.address != pendingRemovedAccountAssetPair.account.address {
                return true
            }

            return account.containsCollectibleAsset(pendingRemovedAccountAssetPair.asset.id)
        }
    }

    private func clearSentAccountAssetPairsIfNeeded(
        for account: Account
    ) {
        sentAccountAssetPairs = sentAccountAssetPairs.filter {
            pendingSentAccountAssetPair in
            if account.address != pendingSentAccountAssetPair.account.address {
                return true
            }

            let matchingCollectibleAsset = account.collectibleAssets.first(
                matching: (\.id, pendingSentAccountAssetPair.asset.id)
            )
            return (matchingCollectibleAsset?.isOwned ?? false)
        }
    }

    private func getPendingStatus(
        asset: CollectibleAsset,
        account: Account
    ) -> Bool {
        let pendingAccountAssetPairs =
        addedAccountAssetPairs +
        removedAccountAssetPairs +
        sentAccountAssetPairs

        let matchingPendingAccountAssetPair = pendingAccountAssetPairs.first(
            matching: (\.asset.id, asset.id)
        )
        return matchingPendingAccountAssetPair?.account.address == account.address
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
