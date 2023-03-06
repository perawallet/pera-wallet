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

//   SelectLocalAssetDataController.swift

import Foundation
import MacaroonUtils

final class SelectLocalAssetDataController:
    SelectAssetDataController,
    SharedDataControllerObserver {
    var eventHandler: ((SelectAssetDataControllerEvent) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()

    private let updatesQueue = DispatchQueue(label: Constants.DispatchQueues.swapLocalAssetSnapshot)
    private var lastSnapshot: Snapshot?

    private var lastQuery: String?

    private var assets: [Asset] = []
    private var searchResults: [Asset] = []

    private(set) var account: Account
    private let filters: [AssetFilterAlgorithm]?
    private let api: ALGAPI
    private let sharedDataController: SharedDataController

    init(
        account: Account,
        filters: [AssetFilterAlgorithm],
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.filters = filters
        self.api = api
        self.sharedDataController = sharedDataController
    }

    subscript(indexPath: IndexPath) -> Asset? {
        return assets[safe: indexPath.item]
    }

    subscript(id: AssetID) -> Asset? {
        return assets.first { $0.id == id }
    }
}

extension SelectLocalAssetDataController {
    func load() {
        assets = ([account.algo] + account.standardAssets.unwrap(or: []))

        filters?.forEach { filter in
            assets = assets.filter { filter.getFormula(asset: $0) }
        }

        searchResults = assets

        deliverContentSnapshot()
    }

    func search(
        for query: String?
    ) {
        guard let query = query else { return }

        lastQuery = query
        searchResults = assets.filter { asset in
            filterByIDOfAsset(asset, query: query) ||
            filterByNameOfAsset(asset, query: query) ||
            filterByUnitNameOfAsset(asset, query: query)
        }

        deliverContentSnapshot()
    }

    private func filterByIDOfAsset(
        _ asset: Asset,
        query: String
    ) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func filterByNameOfAsset(
        _ asset: Asset,
        query: String
    ) -> Bool {
        return asset.naming.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func filterByUnitNameOfAsset(
        _ asset: Asset,
        query: String
    ) -> Bool {
        return asset.naming.unitName.someString.localizedCaseInsensitiveContains(query)
    }

    func resetSearch() {
        lastQuery = nil
        load()
    }
}

extension SelectLocalAssetDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
        }
    }

    private func updateAccountIfNeeded() {
        guard let updatedAccount = sharedDataController.accountCollection[account.address] else {
            return
        }

        if !updatedAccount.isAvailable { return }

        self.account = updatedAccount.value
    }
}

extension SelectLocalAssetDataController {
    private func deliverContentSnapshot() {
        if assets.isEmpty {
            deliverNoContentSnapshot()
            return
        }

         deliverUpdates() {
             [weak self] in
             guard let self = self else {
                 return Snapshot()
             }

             let currency = self.sharedDataController.currency
             let currencyFormatter = self.currencyFormatter

             var snapshot = Snapshot()
             snapshot.appendSections([.assets])

             var selectAssetItems: [SelectAssetItem] = self.searchResults.map {
                 asset in
                 let assetItem = AssetItem(
                     asset: asset,
                     currency: currency,
                     currencyFormatter: currencyFormatter
                 )
                 let listItem = SelectAssetListItem(item: assetItem, account: self.account)
                 return SelectAssetItem.asset(listItem)
             }
             
             if let selectedAccountSortingAlgorithm = self.sharedDataController.selectedAccountAssetSortingAlgorithm {
                 selectAssetItems.sort {
                     if case let .asset(firstItem) = $0,
                        case let .asset(secondItem) = $1 {
                         return selectedAccountSortingAlgorithm.getFormula(
                            asset: firstItem.asset,
                            otherAsset: secondItem.asset
                         )
                     }
                     
                     return false
                 }
             }
             
             snapshot.appendItems(
                 selectAssetItems,
                 toSection: .assets
             )

             return snapshot
         }
    }

    private func deliverNoContentSnapshot() {
        deliverUpdates() {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            let viewModel = SelectAssetNoContentItemViewModel()
            snapshot.appendItems(
                [.empty(.noContent(viewModel))],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverUpdates(
        error: SelectAssetDataController.Error? = nil,
        _ snapshot: @escaping () -> Snapshot
    ) {
        updatesQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()
            self.lastSnapshot = newSnapshot
            let updates = (snapshot: newSnapshot, error: error)
            let event = SelectAssetDataControllerEvent.didUpdate(updates)

            self.publish(event)
        }
    }
}

extension SelectLocalAssetDataController {
    private func publish(
        _ event: SelectAssetDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
