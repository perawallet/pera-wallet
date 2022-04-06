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
    
    private var account: Account
    private var lastSnapshot: Snapshot?
    
    private var searchResults: [Asset] = []
    private var accountAssets: [Asset] = []
    
    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: Constants.DispatchQueues.manageAssetListSnapshot)
    
    private var lastQuery: String? = nil
    
    init(
        _ account: Account,
        _ sharedDataController: SharedDataController
    ) {
        self.account = account
        self.sharedDataController = sharedDataController
        
        fetchAssets()
    }
    
    deinit {
        sharedDataController.remove(self)
    }
    
    subscript (index: Int) -> Asset? {
        return searchResults[safe: index]
    }
    
    func hasSection() -> Bool {
        return !searchResults.isEmpty
    }
}

extension ManageAssetsListLocalDataController {
    func fetchAssets() {
        searchResults.removeAll()
        accountAssets.removeAll()
        account.allAssets.forEach {
            if !$0.state.isPending {
                accountAssets.append($0)
            }
        }
        searchResults = accountAssets
        
        guard let lastQuery = lastQuery else {
            return
        }
        
        search(for: lastQuery)
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
        deliverContentSnapshot()
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
            deliverContentSnapshot()
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
            let currency = self.sharedDataController.currency.value

            self.searchResults.forEach { asset in
                let viewModel: AssetPreviewViewModel

                if let collectibleAsset = asset as? CollectibleAsset {
                    viewModel = AssetPreviewViewModel(collectibleAsset)
                } else {
                    let assetPreviewModel = AssetPreviewModelAdapter.adaptAssetSelection((asset, currency))
                    viewModel = AssetPreviewViewModel(assetPreviewModel)
                }

                let assetItem: ManageAssetSearchItem = .asset(viewModel)
                assetItems.append(assetItem)
            }

            snapshot.appendSections([.assets])
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )
            
            snapshot.reloadItems(assetItems)
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
