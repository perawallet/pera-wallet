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

    var notificationObservations: [NSObjectProtocol] = []

    var eventHandler: ((CollectibleDataControllerEvent) -> Void)?

    var galleryUIStyle: CollectibleGalleryUIStyle = .grid

    var imageSize: CGSize = .zero

    private lazy var assetAmountFormatter = createAssetAmountFormatter()
    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()
    private lazy var searchThrottler = createSearchThrottler()

    private var nextQuery: CollectibleListQuery?
    private var lastQuery: CollectibleListQuery?
    private var lastSnapshot: Snapshot?

    private var accounts: AccountCollection = []

    let galleryAccount: CollectibleGalleryAccount

    private let sharedDataController: SharedDataController
    private let isWatchAccount: Bool

    /// <note>
    /// On layout changes (grid to list or vice versa) we're disabling the list updates to prevent unexpected behaviors.
    private var canPerformUpdates = true

    private var canDeliverUpdatesForAssets = false

    init(
        galleryAccount: CollectibleGalleryAccount,
        sharedDataController: SharedDataController
    ) {
        self.galleryAccount = galleryAccount
        self.sharedDataController = sharedDataController

        self.isWatchAccount = galleryAccount.singleAccount?.value.authorization.isWatch ?? false

        self.startObservingCollectibleAssetActions()
    }

    deinit {
        cancelOngoingSearching()
        sharedDataController.remove(self)
        stopObservingNotifications()
    }
}

extension CollectibleListLocalDataController {
    private func startObservingCollectibleAssetActions() {
        observe(notification: Self.didAddCollectible) {
            [weak self] _ in
            guard let self else { return }
            self.reload()
        }
        observe(notification: Self.didRemoveCollectible) {
            [weak self] _ in
            guard let self else { return }
            self.reload()
        }
        observe(notification: Self.didSendCollectible) {
            [weak self] _ in
            guard let self else { return }
            self.reload()
        }
    }
}

extension CollectibleListLocalDataController {
    func load(query: CollectibleListQuery?) {
        nextQuery = query

        if canDeliverUpdatesForAssets {
            loadNext(query: query)
        } else {
            loadFirst(query: query)
        }
    }

    private func loadNext(query: CollectibleListQuery?) {
        if query == lastQuery {
            nextQuery = nil
            return
        }

        if query?.keyword == lastQuery?.keyword {
            customize(query: query)
        } else {
            search(query: query)
        }
    }

    private func customize(query: CollectibleListQuery?) {
        cancelOngoingSearching()
        deliverUpdatesForLoading()

        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { query == self.nextQuery && self.canPerformUpdates },
                query: query
            )
        }
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }

    private func search(query: CollectibleListQuery?) {
        cancelOngoingLoading()
        deliverUpdatesForLoading()

        searchThrottler.performNext {
            [weak self] in
            guard let self else { return }

            let task = AsyncTask {
                [weak self] completionBlock in
                guard let self else { return }

                defer {
                    completionBlock()
                }

                self.deliverUpdatesForContent(
                    when: { query == self.nextQuery && self.canPerformUpdates },
                    query: query
                )
            }
            self.asyncLoadingQueue.add(task)
            self.asyncLoadingQueue.resume()
        }
    }

    private func loadFirst(query: CollectibleListQuery?) {
        deliverUpdatesForLoading()

        lastQuery = query
        nextQuery = nil
        sharedDataController.add(self)
    }

    func load(galleryUIStyle: CollectibleGalleryUIStyle) {
        cancelOngoingLoading()
        deliverUpdatesForLoading()

        let task = AsyncTask(
            execution: {
                [weak self] completionBlock in
                guard let self else { return }

                defer {
                    completionBlock()
                }

                self.deliverUpdatesForContent(
                    when: {
                        self.nextQuery == nil &&
                        self.galleryUIStyle == galleryUIStyle &&
                        self.canPerformUpdates &&
                        self.canDeliverUpdatesForAssets
                    },
                    query: self.lastQuery
                )
            }
        )

        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }

    private func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { self.nextQuery == nil && self.canPerformUpdates },
                query: self.lastQuery
            )
        }
        asyncLoadingQueue.add(task)
    }

    private func cancelOngoingSearching() {
        searchThrottler.cancelAll()
        cancelOngoingLoading()
    }

    private func cancelOngoingLoading() {
        asyncLoadingQueue.cancel()
    }
}

extension CollectibleListLocalDataController {
    func startUpdates() {
        canPerformUpdates = true
    }

    func stopUpdates() {
        canPerformUpdates = false
    }
}

extension CollectibleListLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            canDeliverUpdatesForAssets = false

            deliverInitialUpdates()
        case .didFinishRunning:
            canDeliverUpdatesForAssets = true

            switch galleryAccount {
            case .single(let account):
                guard let upToDateAccount = sharedDataController.accountCollection[account.value.address] else {
                    return
                }

                if case .failed = upToDateAccount.status {
                    eventHandler?(.didFinishRunning(hasError: true))
                    return
                }

                eventHandler?(.didFinishRunning(hasError: false))

                accounts = [upToDateAccount]

                reload()
            case .all:
                let upToDateAccounts = sharedDataController.accountCollection

                for upToDateAccount in upToDateAccounts {
                    if case .failed = upToDateAccount.status {
                        eventHandler?(.didFinishRunning(hasError: true))
                        return
                    }
                }

                eventHandler?(.didFinishRunning(hasError: false))

                accounts = upToDateAccounts

                reload()
            }
        default:
            break
        }
    }
}

extension CollectibleListLocalDataController {
    private func deliverInitialUpdates() {
        if sharedDataController.isPollingAvailable {
            deliverUpdatesForLoading()
        } else {
            deliverUpdatesForNoContent()
        }
    }

    private func deliverUpdatesForLoading() {
        let updates = makeUpdatesForLoading()
        publish(updates: updates)
    }

    private func makeUpdatesForLoading() -> Updates {
        var snapshot = Snapshot()
        appendSectionsForHeader(into: &snapshot, withCollectibleCount: .zero)
        appendSectionsForUIActions(into: &snapshot)
        appendSectionsForAssetsLoading(into: &snapshot)
        return Updates(snapshot: snapshot)
    }

    private func deliverUpdatesForNoContent() {
        let updates = makeUpdatesForNoContent()
        publish(updates: updates)
    }

    private func makeUpdatesForNoContent(collectibleList: CollectibleList? = nil) -> Updates {
        var snapshot = Snapshot()
        appendSectionsForNoContent(into: &snapshot, collectibleList: collectibleList)
        return Updates(snapshot: snapshot)
    }

    private func deliverUpdatesForContent(
        when condition: () -> Bool,
        query: CollectibleListQuery?
    ) {
        let updates = makeUpdatesForContent(query: query)

        if !condition() { return }

        self.lastQuery = query
        self.nextQuery = nil

        self.publish(updates: updates)
    }

    private func makeUpdatesForContent(
        query: CollectibleListQuery?
    ) -> Updates {
        let pendingCollectibleItems = makePendingCollectibleListItems()
        let collectibleList = makeCollectibleList(query: query)

        let shouldShowEmptyContent = pendingCollectibleItems.isEmpty && collectibleList.isEmpty

        if shouldShowEmptyContent {
            let isSearching = !(query?.keyword.isNilOrEmpty ?? true)
            return isSearching ? makeUpdatesForSearchNoContent(query) : makeUpdatesForNoContent(collectibleList: collectibleList)
        }

        let visibleCollectibleItems = collectibleList.visibleItems

        var snapshot = Snapshot()
        appendSectionsForHeader(into: &snapshot, withCollectibleCount: visibleCollectibleItems.count)
        appendSectionsForUIActions(into: &snapshot)

        let assetItems = pendingCollectibleItems + visibleCollectibleItems
        snapshot.appendSections([.collectibles])
        snapshot.appendItems(
            assetItems,
            toSection: .collectibles
        )

        return Updates(snapshot: snapshot)
    }

    private func makeUpdatesForSearchNoContent(_ query: CollectibleListQuery?) -> Updates {
        var snapshot = Snapshot()
        appendSectionsForSearchNoContent(into: &snapshot, query: query)
        return Updates(snapshot: snapshot)
    }
}

extension CollectibleListLocalDataController {
    private func appendSectionsForHeader(
        into snapshot: inout Snapshot,
        withCollectibleCount count: Int
    ) {
        if isWatchAccount {
            appendSectionsForWatchAccountHeader(
                into: &snapshot,
                withCollectibleCount: count
            )
        } else {
            appendSectionsForNormalAccountHeader(
                into: &snapshot,
                withCollectibleCount: count
            )
        }
    }

    private func appendSectionsForNormalAccountHeader(
        into snapshot: inout Snapshot,
        withCollectibleCount count: Int
    ) {
        let items = makeNormalAccountHeaderItems(withCollectibleCount: count)
        snapshot.appendSections([.header])
        snapshot.appendItems(
            items,
            toSection: .header
        )
    }

    private func appendSectionsForWatchAccountHeader(
        into snapshot: inout Snapshot,
        withCollectibleCount count: Int
    ) {
        let items = makeWatchAccountHeaderItems(withCollectibleCount: count)
        snapshot.appendSections([.header])
        snapshot.appendItems(
            items,
            toSection: .header
        )
    }

    private func appendSectionsForUIActions(into snapshot: inout Snapshot) {
        let items = makeUIActionsItems()
        snapshot.appendSections([.uiActions])
        snapshot.appendItems(
            items,
            toSection: .uiActions
        )
    }

    private func appendSectionsForNoContent(
        into snapshot: inout Snapshot,
        collectibleList: CollectibleList? = nil
    ) {
        let viewModel = CollectiblesNoContentWithActionViewModel(
            hiddenCollectibleCount: collectibleList?.hiddenCount ?? .zero,
            isWatchAccount: isWatchAccount
        )
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty(.noContent(viewModel))],
            toSection: .empty
        )
    }

    private func appendSectionsForSearchNoContent(
        into snapshot: inout Snapshot,
        query: CollectibleListQuery?
    ) {
        func appendSectionsForSearchNoContent(into snapshot: inout Snapshot) {
            let items = makeSearchNoContentItems()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                items,
                toSection: .empty
            )
        }

        appendSectionsForHeader(into: &snapshot, withCollectibleCount: .zero)
        appendSectionsForUIActions(into: &snapshot)
        appendSectionsForSearchNoContent(into: &snapshot)
    }

    private func appendSectionsForAssetsLoading(into snapshot: inout Snapshot) {
        let items = makeAssetsLoadingItems()
        snapshot.appendSections([.collectibles])
        snapshot.appendItems(
            items,
            toSection: .collectibles
        )
    }
}

extension CollectibleListLocalDataController {
    private func makePendingCollectibleListItems() -> [CollectibleListItem] {
        let pendingOptInAssets = getPendingOptInAssets()
        let pendingOptInCollectibleItems = pendingOptInAssets.compactMap {
            return $0.isCollectibleAsset ? makePendingCollectibleAssetOptInItem($0) : nil
        }

        let pendingOptOutAssets = getPendingOptOutAssets()
        let pendingOptOutCollectibleItems = pendingOptOutAssets.compactMap {
            return $0.isCollectibleAsset ? makePendingCollectibleAssetOptOutItem($0) : nil
        }

        let pendingSendPureCollectibleAssets = getPendingSendPureCollectibleAssets()
        let pendingSendPureCollectibleItems =
            pendingSendPureCollectibleAssets.map(makePendingPureCollectibleAssetSendItem)

        return pendingOptInCollectibleItems + pendingOptOutCollectibleItems + pendingSendPureCollectibleItems
    }

    private func getPendingOptInAssets() -> [OptInBlockchainUpdate] {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        if let account = galleryAccount.singleAccount?.value {
            let updates = monitor.filterPendingOptInAssetUpdates(for: account)
            return updates.map(\.value)
        } else {
            return monitor.filterPendingOptInAssetUpdates()
        }
    }

    private func getPendingOptOutAssets() -> [OptOutBlockchainUpdate] {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        if let account = galleryAccount.singleAccount?.value {
            let updates = monitor.filterPendingOptOutAssetUpdates(for: account)
            return updates.map(\.value)
        } else {
            return monitor.filterPendingOptOutAssetUpdates()
        }
    }

    private func getPendingSendPureCollectibleAssets() -> [SendPureCollectibleAssetBlockchainUpdate] {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        if let account = galleryAccount.singleAccount?.value {
            let updates = monitor.filterPendingSendPureCollectibleAssetUpdates(for: account)
            return updates.map(\.value)
        } else {
            return monitor.filterPendingSendPureCollectibleAssetUpdates()
        }
    }

    private func makeCollectibleList(query: CollectibleListQuery?) -> CollectibleList {
        let collectibleAssets = formSortedCollectibleAssets(query)

        let collectibleItems: [CollectibleListItem] = collectibleAssets.compactMap { collectibleAsset in
            guard let account = account(for: collectibleAsset) else {
                return nil
            }

            if let query, !query.matches(asset: collectibleAsset, galleryAccount: galleryAccount, account: account) {
                return nil
            }

            /// <note>
            /// Pending asset requests has its own item different from the asset item.
            if hasAnyPendingAssetRequest(asset: collectibleAsset, account: account) {
                return nil
            }

            let item = makeCollectibleAssetItem(account: account, asset: collectibleAsset)
            return item
        }

        let collectibleList = CollectibleList(
            allItems: collectibleAssets,
            visibleItems: collectibleItems
        )
        return collectibleList
    }
}

extension CollectibleListLocalDataController {
    private func makeUIActionsItems() -> [CollectibleListItem] {
        return [ .uiActions ]
    }

    private func makeNormalAccountHeaderItems(withCollectibleCount count: Int) -> [CollectibleListItem] {
        let viewModel = ManagementItemViewModel(
            .collectible(
                count: count,
                isWatchAccountDisplay: false
            )
        )
        return [ .header(viewModel) ]
    }

    private func makeWatchAccountHeaderItems(withCollectibleCount count: Int) -> [CollectibleListItem] {
        let viewModel = ManagementItemViewModel(
            .collectible(
                count: count,
                isWatchAccountDisplay: true
            )
        )
        return [ .watchAccountHeader(viewModel) ]
    }

    private func makeSearchNoContentItems() -> [CollectibleListItem] {
        return [ .empty(.noContentSearch) ]
    }

    private func makeAssetsLoadingItems() -> [CollectibleListItem] {
        if galleryUIStyle.isGrid {
            return [ .collectibleAssetsLoading(.grid) ]
        } else {
            return [ .collectibleAssetsLoading(.list) ]
        }
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makeCollectibleAssetGridItem(account: account, asset: asset)
        } else {
            return makeCollectibleAssetListItem(account: account, asset: asset)
        }
    }

    private func makePendingCollectibleAssetOptOutItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makePendingCollectibleAssetOptOutGridItem(update)
        } else {
            return makePendingCollectibleAssetOptOutListItem(update)
        }
    }

    private func makePendingCollectibleAssetOptInItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makePendingCollectibleAssetOptInGridItem(update)
        } else {
            return makePendingCollectibleAssetOptInListItem(update)
        }
    }

    private func makePendingPureCollectibleAssetSendItem(_ update: SendPureCollectibleAssetBlockchainUpdate) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makePendingPureCollectibleAssetSendGridItem(update)
        } else {
            return makePendingPureCollectibleAssetSendListItem(update)
        }
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetGridItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: assetAmountFormatter
        )
        let item = CollectibleListCollectibleAssetGridItem(
            imageSize: imageSize,
            item: collectibleAssetItem
        )
        return .collectibleAsset(.grid(item))
    }

    private func makePendingCollectibleAssetOptInGridItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetGridItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(item))
    }

    private func makePendingCollectibleAssetOptOutGridItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetGridItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(item))
    }

    private func makePendingPureCollectibleAssetSendGridItem(_ update: SendPureCollectibleAssetBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetGridItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(item))
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetListItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: assetAmountFormatter
        )
        let item = CollectibleListCollectibleAssetListItem(item: collectibleAssetItem)
        return .collectibleAsset(.list(item))
    }

    private func makePendingCollectibleAssetOptInListItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(.list(item))
    }

    private func makePendingCollectibleAssetOptOutListItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(.list(item))
    }

    private func makePendingPureCollectibleAssetSendListItem(_ update: SendPureCollectibleAssetBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(.list(item))
    }
}

extension CollectibleListLocalDataController {
    private func account(for asset: CollectibleAsset) -> Account? {
        let address = asset.optedInAddress
        let account = address.unwrap { accounts.account(for: $0) }
        return account
    }
}

extension CollectibleListLocalDataController {
    private func formSortedCollectibleAssets(_ query: CollectibleListQuery?) -> [CollectibleAsset] {
        func formCollectibleAssets(
            _ collectibles: [CollectibleAsset],
            appendingCollectiblesOf account: AccountHandle
        ) -> [CollectibleAsset] {
            let newCollectibles = account.value.collectibleAssets.someArray
            return collectibles + newCollectibles
        }

        if let collectibleSortingAlgorithm = query?.sortingAlgorithm {
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

private extension CollectibleListLocalDataController {
    struct CollectibleList {
        var totalCount: Int {
            return allItems.count
        }
        var visibleCount: Int {
            return visibleItems.count
        }
        var hiddenCount: Int {
            return totalCount - visibleItems.count
        }

        var isEmpty: Bool {
            return visibleItems.isEmpty
        }

        let allItems: [CollectibleAsset]
        let visibleItems: [CollectibleListItem]
    }
}

extension CollectibleListLocalDataController {
    private func hasAnyPendingAssetRequest(
        asset: CollectibleAsset,
        account: Account
    ) -> Bool {
        let hasPendingOptOutRequest = hasPendingOptOutRequest(
            asset: asset,
            account: account
        )
        if hasPendingOptOutRequest {
            return true
        }

        let hasPendingSendPureCollectibleAssetRequest = hasPendingSendPureCollectibleAssetRequest(
            asset: asset,
            account: account
        )
        if hasPendingSendPureCollectibleAssetRequest {
            return true
        }

        return false
    }

    private func hasPendingOptOutRequest(
        asset: CollectibleAsset,
        account: Account
    ) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        return monitor.hasPendingOptOutRequest(
            assetID: asset.id,
            for: account
        )
    }

    private func hasPendingSendPureCollectibleAssetRequest(
        asset: CollectibleAsset,
        account: Account
    ) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        return monitor.hasPendingSendPureCollectibleAssetRequest(
            assetID: asset.id,
            for: account
        )
    }
}

extension CollectibleListLocalDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }

    private func publish(event: CollectibleDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }

            self.eventHandler?(event)
        }
    }
}

extension CollectibleListLocalDataController {
    private func createAsyncLoadingQueue() -> AsyncSerialQueue {
        let underlyingQueue = DispatchQueue(
            label: "pera.queue.collectibles.updates",
            qos: .userInitiated
        )
        return .init(
            name: "collectibleListLocalDataController.asyncLoadingQueue",
            underlyingQueue: underlyingQueue
        )
    }

    private func createSearchThrottler() -> Throttler {
        return .init(intervalInSeconds: 0.4)
    }

    private func createAssetAmountFormatter() -> CollectibleAmountFormatter {
        return .init()
    }
}

extension CollectibleListLocalDataController {
    typealias Updates = CollectibleListUpdates
    typealias Snapshot = CollectibleListUpdates.Snapshot
}
