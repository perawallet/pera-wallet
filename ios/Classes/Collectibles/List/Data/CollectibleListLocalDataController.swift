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

    static var didChangeFilter: Notification.Name {
        return .init(rawValue: Constants.Notification.collectibleListDidChangeFilter)
    }

    static var collectibleListFilterInfoKey: String {
        return Constants.Notification.InfoKey.collectibleListFilter
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

    private var accounts: AccountCollection = []
    private let sharedDataController: SharedDataController
    private let cache: Cache

    typealias AccountAssetPair = (account: Account, asset: CollectibleAsset)
    private var addedAccountAssetPairs: [AccountAssetPair] = []
    private var removedAccountAssetPairs: [AccountAssetPair] = []
    private var sentAccountAssetPairs: [AccountAssetPair] = []

    private let isWatchAccount: Bool

    var imageSize: CGSize = .zero

    private var lastQuery: String?

    private(set) var currentFilter: Filter {
        didSet { cache.filter = currentFilter }
    }

    private var hiddenCollectibleCount: Int = .zero

    init(
        galleryAccount: CollectibleGalleryAccount,
        sharedDataController: SharedDataController
    ) {
        self.galleryAccount = galleryAccount
        self.sharedDataController = sharedDataController

        self.isWatchAccount = galleryAccount.singleAccount?.value.isWatchAccount() ?? false

        let cache = Cache()
        self.cache = cache
        self.currentFilter = cache.filter ?? .owned

        self.observePendingAccountAssetPairs()
        self.observeDidChangeFilter()
    }

    deinit {
        sharedDataController.remove(self)
        stopObservingNotifications()
    }
}

extension CollectibleListLocalDataController {
    func load() {
        sharedDataController.add(self)
    }

    func reload() {
        deliverContentSnapshot(with: lastQuery)
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
    func filter(
        by filter: Filter
    ) {
        if filter == currentFilter {
            return
        }

        notifyDidChangeFilterObservers(filter)
    }

    private func notifyDidChangeFilterObservers(_ filter: Filter) {
        NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didChangeFilter,
            object: nil,
            userInfo: [
                Self.collectibleListFilterInfoKey: filter
            ]
        )
    }

    private func observeDidChangeFilter() {
        observe(notification: Self.didChangeFilter) {
            [weak self] notification in
            guard let self = self else { return }

            if let filter =
                notification.userInfo?[
                    Self.collectibleListFilterInfoKey
                ] as? Filter {

                self.currentFilter = filter

                self.deliverContentSnapshot(with: self.lastQuery)
            }
        }
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

                accounts = [updatedAccount]

                if let lastQuery = lastQuery {
                    search(for: lastQuery)
                } else {
                    deliverContentSnapshot()
                }
            case .all:
                let accounts = sharedDataController.accountCollection

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

                self.accounts = accounts

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

        clearPendingAssetPairsIfNeeded()

        var collectibleItems: [CollectibleListItem] = []

        let collectibleAssets = formSortedCollectibleAssets()
        collectibleAssets.forEach { collectibleAsset in
            guard
                let address = collectibleAsset.optedInAddress,
                let account = accounts.account(for: address)
            else {
                return
            }

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

        var pendingCollectibleItems: [CollectibleListItem] = []

        let pendingAccountAssetPairs =
        addedAccountAssetPairs +
        removedAccountAssetPairs +
        sentAccountAssetPairs

        pendingAccountAssetPairs.forEach { pendingAccountAssetPair in
            let pendingCollectibleAsset = pendingAccountAssetPair.asset
            let pendingCollectibleAccount = pendingAccountAssetPair.account

            let account = accounts.account(for: pendingCollectibleAccount.address)

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

            if self.isWatchAccount {
                self.addWatchAccountHeaderContent(
                    withCollectibleCount: collectibleItems.count,
                    to: &snapshot
                )
            } else {
                self.addHeaderContent(
                    withCollectibleCount: collectibleItems.count,
                    to: &snapshot
                )
            }

            snapshot.appendSections([.search, .collectibles])

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
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()

            if self.isWatchAccount {
                self.addWatchAccountHeaderContent(
                    withCollectibleCount: .zero,
                    to: &snapshot
                )
            } else {
                self.addHeaderContent(
                    withCollectibleCount: .zero,
                    to: &snapshot
                )
            }

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

    private func addHeaderContent(
        withCollectibleCount count: Int,
        to snapshot: inout Snapshot
    ) {
        let headerItem: CollectibleListItem = .header(
            ManagementItemViewModel(
                .collectible(
                    count: count,
                    isWatchAccountDisplay: false
                )
            )
        )

        snapshot.appendSections([.header])
        snapshot.appendItems(
            [headerItem],
            toSection: .header
        )
    }

    private func addWatchAccountHeaderContent(
        withCollectibleCount count: Int,
        to snapshot: inout Snapshot
    ) {
        let headerItem: CollectibleListItem = .watchAccountHeader(
            ManagementItemViewModel(
                .collectible(
                    count: count,
                    isWatchAccountDisplay: true
                )
            )
        )

        snapshot.appendSections([.header])
        snapshot.appendItems(
            [headerItem],
            toSection: .header
        )
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

    private func clearPendingAssetPairsIfNeeded() {
        accounts.forEach {
            let account = $0.value
            clearAddedAccountAssetPairsIfNeeded(for: account)
            clearRemovedAccountAssetPairsIfNeeded(for: account)
            clearSentAccountAssetPairsIfNeeded(for: account)
        }
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

            let matchingCollectibleAsset = account.collectibleAssets?.first(
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
    private func formSortedCollectibleAssets() -> [CollectibleAsset] {
        func formCollectibleAssets(
            _ collectibles: [CollectibleAsset],
            appendingCollectiblesOf account: AccountHandle
        ) -> [CollectibleAsset] {
            let newCollectibles = account.value.collectibleAssets.someArray
            return collectibles + newCollectibles
        }

        if let collectibleSortingAlgorithm = sharedDataController.selectedCollectibleSortingAlgorithm {
            let collectibleAssets = accounts.reduce([], formCollectibleAssets)
            return collectibleAssets.sorted(collectibleSortingAlgorithm)
        }

        let sortedAccounts: [AccountHandle]
        if let accountSortingAlgorithm = sharedDataController.selectedAccountSortingAlgorithm {
            sortedAccounts = accounts.sorted(accountSortingAlgorithm)
        } else {
            sortedAccounts = accounts.map { $0 }
        }

        return sortedAccounts.reduce([], formCollectibleAssets)
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
    private final class Cache: Storable {
        typealias Object = Any

        var filter: Filter? {
            get {
                let aRawValue = userDefaults.integer(forKey: filterKey)
                return Filter(rawValue: aRawValue)
            }
            set {
                if newValue == filter {
                    return
                }

                userDefaults.set(newValue?.rawValue, forKey: filterKey)
            }
        }

        private let filterKey = "cache.key.collectibleListFilter"
    }
}
