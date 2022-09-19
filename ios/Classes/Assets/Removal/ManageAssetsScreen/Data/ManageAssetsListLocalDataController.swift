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

//   ManageAssetsListLocalDataController.swift

import Foundation
import MacaroonUtils

final class ManageAssetsListLocalDataController:
    ManageAssetsListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((ManageAssetsListDataControllerEvent) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()
    
    private(set) var account: Account

    private var lastSnapshot: Snapshot?
    
    private var searchResults: [Asset] = []
    private var accountAssets: [Asset] = []
    
    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: Constants.DispatchQueues.manageAssetListSnapshot)

    private var lastQuery: String? = nil

    private var assetItems: [AssetID: ManageAssetSearchItem] = [:]

    weak var dataSource: ManageAssetsListDataSource?

    init(
        account: Account,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.sharedDataController = sharedDataController

        sharedDataController.add(self)
    }
    
    deinit {
        sharedDataController.remove(self)
    }
    
    subscript(index: Int) -> Asset? {
        return searchResults[safe: index]
    }
    
    subscript(assetID: AssetID) -> Asset? {
        return searchResults.first(matching: (\.id, assetID))
    }
}

extension ManageAssetsListLocalDataController {
    func fetchAssets() {
        accountAssets = account.allAssets ?? []
        searchResults = accountAssets

        if let lastQuery = lastQuery {
            search(for: lastQuery)
        } else {
            deliverContentSnapshot()
        }
    }

    func search(for query: String) {
        lastQuery = query
        searchResults = accountAssets.filter { asset in
            isAssetContainsID(asset, query: query) ||
            isAssetContainsName(asset, query: query) ||
            isAssetContainsUnitName(asset, query: query)
        }
        
        deliverContentSnapshot()
    }

    private func isAssetContainsID(_ asset: Asset, query: String) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: Asset, query: String) -> Bool {
        return asset.naming.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: Asset, query: String) -> Bool {
        return asset.naming.unitName.someString.localizedCaseInsensitiveContains(query)
    }

    func resetSearch() {
        lastQuery = nil
        fetchAssets()
    }
}

extension ManageAssetsListLocalDataController {
    func hasOptedOut(_ asset: Asset) -> OptOutStatus {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptedOut = monitor.hasPendingOptOutRequest(
            assetID: asset.id,
            for: account
        )
        let hasAlreadyOptedOut = account[asset.id] == nil

        switch (hasPendingOptedOut, hasAlreadyOptedOut) {
        case (true, false): return .pending
        case (true, true): return .optedOut
        case (false, true): return .optedOut
        case (false, false): return .rejected
        }
    }
}

extension ManageAssetsListLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
            fetchAssets()
        }
    }

    private func updateAccountIfNeeded() {
        let updatedAccount = sharedDataController.accountCollection[account.address]

        guard let account = updatedAccount else { return }

        if !account.isAvailable { return }

        self.account = account.value
    }
}

extension ManageAssetsListLocalDataController {
    private func deliverContentSnapshot() {
        guard !accountAssets.isEmpty else {
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
            
            var assetItems: [ManageAssetSearchItem] = []

            let currency = self.sharedDataController.currency
            let currencyFormatter = self.currencyFormatter

            self.searchResults.forEach { asset in
                let item = AssetItem(
                    asset: asset,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let optOutAssetListItem = OptOutAssetListItem(item: item)
                let assetItem = ManageAssetSearchItem.asset(optOutAssetListItem)
                assetItems.append(assetItem)

                self.assetItems[asset.id] = assetItem
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
                [.empty(AssetListSearchNoContentViewModel(hasBody: false))],
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
                [.empty(AssetListSearchNoContentViewModel(hasBody: true))],
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

extension ManageAssetsListLocalDataController {
    private func publish(
        _ event: ManageAssetsListDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }
            
            self.eventHandler?(event)
        }
    }
}
