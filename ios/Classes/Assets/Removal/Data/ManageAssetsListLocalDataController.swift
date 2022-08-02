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
    private var removedAssetDetails: [Asset] = []
    
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
        searchResults.removeAll()
        accountAssets.removeAll()
        account.allAssets?.forEach {
            if !$0.state.isPending {
                accountAssets.append($0)
            }
        }
        searchResults = accountAssets

        if let lastQuery = lastQuery {
            search(for: lastQuery)
        } else {
            deliverContentSnapshot()
        }
    }
    
    func load() {
        sharedDataController.add(self)
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
        return String(asset.presentation.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: Asset, query: String) -> Bool {
        return asset.presentation.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: Asset, query: String) -> Bool {
        return asset.presentation.unitName.someString.localizedCaseInsensitiveContains(query)
    }
    
    func resetSearch() {
        lastQuery = nil
        fetchAssets()
    }

    private func clearRemovedAssetDetailsIfNeeded() {
        removedAssetDetails = removedAssetDetails.filter {
            account.containsAsset($0.id)
        }
    }

    func removeAsset(
        _ asset: Asset
    ) {
        let isAlreadyPending = removedAssetDetails.contains {
            $0.id == asset.id
        }

        guard !isAlreadyPending else {
            return
        }

        removedAssetDetails.append(asset)

        guard let dataSource = dataSource,
              let assetItemToDelete = assetItems[asset.id] else {
            return
        }

        let viewModel = PendingAssetPreviewViewModel(
            AssetPreviewModelAdapter.adaptRemovingAsset(asset)
        )

        let pendingItem: ManageAssetSearchItem =
            .pendingAsset(
                viewModel
            )

        var snapshot = dataSource.snapshot()

        snapshot.deleteItems([ assetItemToDelete ])

        snapshot.appendItems(
            [ pendingItem ],
            toSection: .assets
        )

        assetItems.removeValue(forKey: asset.id)

        deliverSnapshot {
            return snapshot
        }
    }
}

extension ManageAssetsListLocalDataController {
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
            if let updatedAccount = sharedDataController.accountCollection[account.address] {
                account = updatedAccount.value
            }
            fetchAssets()
        default:
            break
        }
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

            self.clearRemovedAssetDetailsIfNeeded()

            self.searchResults.forEach { asset in
                if self.removedAssetDetails.contains(where: { removedAsset in
                    asset.id == removedAsset.id
                }) {
                    return
                }

                let viewModel: AssetPreviewViewModel

                if let collectibleAsset = asset as? CollectibleAsset {
                    let draft = CollectibleAssetPreviewSelectionDraft(
                        asset: collectibleAsset,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                    viewModel = AssetPreviewViewModel(draft)
                } else {
                    let assetItem = AssetItem(
                        asset: asset,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                    let assetPreview = AssetPreviewModelAdapter.adaptAssetSelection(assetItem)
                    viewModel = AssetPreviewViewModel(assetPreview)
                }

                let assetItem: ManageAssetSearchItem = .asset(
                    AssetPreviewWithRemoveActionViewModel(
                        contentViewModel: viewModel
                    )
                )
                assetItems.append(assetItem)

                self.assetItems[asset.id] = assetItem
            }

            self.removedAssetDetails.forEach { asset in
                let viewModel = PendingAssetPreviewViewModel(
                    AssetPreviewModelAdapter.adaptRemovingAsset(asset)
                )

                let pendingItem: ManageAssetSearchItem =
                    .pendingAsset(
                        viewModel
                    )
                assetItems.append(pendingItem)
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
