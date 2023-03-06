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
//   AssetListViewAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class AssetListViewAPIDataController:
    AssetListViewDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AssetListViewDataControllerEvent) -> Void)?

    private(set) var account: Account

    private var assets: [AssetDecoration] = []

    private var lastSnapshot: Snapshot?

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    private var draft = AssetSearchQuery()

    private var ongoingEndpoint: EndpointOperatable?
    private var ongoingEndpointToLoadNextPage: EndpointOperatable?

    private var hasNextPage: Bool {
        return draft.cursor != nil
    }

    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.optinAssets.updates",
        qos: .userInitiated
    )

    init(
        account: Account,
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.api = api
        self.sharedDataController = sharedDataController

        sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension AssetListViewAPIDataController {
    func load() {
        deliverLoadingSnapshot()
        loadData()
    }

    func search(for query: String?) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.draft.query = query
            self.draft.cursor = nil

            self.loadData()
        }
    }

    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        if ongoingEndpointToLoadNextPage != nil { return }

        if !hasNextPage { return }

        if indexPath.item < assets.count - 3 { return }

        ongoingEndpointToLoadNextPage = api.searchAssets(
            draft,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else { return }

            self.ongoingEndpointToLoadNextPage = nil

            switch response {
            case let .success(searchResults):
                let results = self.assets + searchResults.results
                self.assets = results
                self.draft.cursor = searchResults.nextCursor

                self.deliverContentSnapshot(next: true)
            case .failure:
                /// <todo>
                /// Handle error properly.
                break
            }
        }
    }

    private func loadData() {
        cancelOngoingEndpoint()

        ongoingEndpoint = api.searchAssets(
            draft,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else { return }

            self.ongoingEndpoint = nil

            switch response {
            case let .success(searchResults):
                self.assets = searchResults.results
                self.draft.cursor = searchResults.nextCursor

                self.deliverContentSnapshot(next: false)
            case .failure:
                /// <todo>
                /// Handle error properly.
                break
            }
        }
    }

    private func cancelOngoingEndpoint() {
        ongoingEndpointToLoadNextPage?.cancel()
        ongoingEndpointToLoadNextPage = nil

        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension AssetListViewAPIDataController {
    func hasOptedIn(_ asset: AssetDecoration) -> OptInStatus {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptedIn = monitor.hasPendingOptInRequest(
            assetID: asset.id,
            for: account
        )
        let hasAlreadyOptedIn = account[asset.id] != nil

        switch (hasPendingOptedIn, hasAlreadyOptedIn) {
        case (true, false): return .pending
        case (true, true): return .optedIn
        case (false, true): return .optedIn
        case (false, false): return .rejected
        }
    }
}

/// <mark>
/// SharedDataControllerObserver
extension AssetListViewAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
            publish(.didUpdateAccount)
        }
    }

    private func updateAccountIfNeeded() {
        let updatedAccount = sharedDataController.accountCollection[account.address]

        guard let account = updatedAccount else { return }

        if !account.isAvailable { return }

        self.account = account.value
    }
}

extension AssetListViewAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot(next: false) {
            var snapshot = Snapshot()
            snapshot.appendSections([.assets])
            snapshot.appendItems([.loading("1"), .loading("2")], toSection: .assets)
            return snapshot
        }
    }

    private func deliverContentSnapshot(next: Bool) {
        guard !self.assets.isEmpty else {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot(next: next) {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            snapshot.appendSections([ .assets ])

            let assetItems: [AssetListViewItem] = self.assets.map {
                let item = OptInAssetListItem(asset: $0)
                return AssetListViewItem.asset(item)
            }
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot(next: false) {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.noContent],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSnapshot(
        next: Bool,
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()

            self.lastSnapshot = newSnapshot

            let event: AssetListViewDataControllerEvent
            if next {
                event = .didUpdateNextAssets(newSnapshot)
            } else {
                event = .didUpdateAssets(newSnapshot)
            }

            self.publish(event)
        }
    }
}

extension AssetListViewAPIDataController {
    private func publish(
        _ event: AssetListViewDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
