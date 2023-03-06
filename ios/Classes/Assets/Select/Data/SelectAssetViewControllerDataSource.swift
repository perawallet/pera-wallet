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
//   SelectAssetViewControllerDataSource.swift

import Foundation
import UIKit
import MacaroonUtils

final class SelectAssetViewControllerDataSource:
    NSObject,
    UICollectionViewDataSource {
    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var collectibleAmountFormatter = CollectibleAmountFormatter()

    private var itemIdentifiers: [SelectAssetListItemIdentifier] = []

    private let account: Account
    private let sharedDataController: SharedDataController

    init(
        account: Account,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.sharedDataController = sharedDataController

        super.init()
    }
}

extension SelectAssetViewControllerDataSource {
    func loadData(completion: @escaping () -> Void) {
        asyncBackground {
            [weak self] in
            guard let self = self else { return }

            var itemIdentifiers: [SelectAssetListItemIdentifier] = []

            let algoItemIdentifier = self.makeAssetListItemIdentifier(self.account.algo)
            itemIdentifiers.append(algoItemIdentifier)

            for blockchainAsset in self.account.allAssets.someArray {
                let asset = self.account[blockchainAsset.id]

                switch asset {
                case let standardAsset as StandardAsset:
                    let assetListItemIdentifier = self.makeAssetListItemIdentifier(standardAsset)
                    itemIdentifiers.append(assetListItemIdentifier)
                case let collectibleAsset as CollectibleAsset where collectibleAsset.isOwned:
                    let collectibleAssetListItemIdentifier = self.makeCollectibleAssetListItemIdentifier(collectibleAsset)
                    itemIdentifiers.append(collectibleAssetListItemIdentifier)
                default:
                    break
                }
            }

            if let selectedAccountSortingAlgorithm = self.sharedDataController.selectedAccountAssetSortingAlgorithm {
                itemIdentifiers.sort {
                    return selectedAccountSortingAlgorithm.getFormula(
                        asset: $0.asset,
                        otherAsset: $1.asset
                    )
                }
            }
            
            self.itemIdentifiers = itemIdentifiers
            
            asyncMain(execute: completion)
        }
    }

    private func makeAssetListItemIdentifier(_ asset: Asset) -> SelectAssetListItemIdentifier {
        let item = AssetItem(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter,
            currencyFormattingContext: .listItem
        )
        let listItem = SelectAssetListItem(item: item, account: account)
        return .asset(listItem)
    }

    private func makeCollectibleAssetListItemIdentifier(_ asset: CollectibleAsset) -> SelectAssetListItemIdentifier {
        let item = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let listItem = SelectCollectibleAssetListItem(item: item)
        return .collectibleAsset(listItem)
    }
}

extension SelectAssetViewControllerDataSource {
    func itemIdentifier(for indexPath: IndexPath) -> SelectAssetListItemIdentifier? {
        return itemIdentifiers[safe: indexPath.item]
    }

    var isEmpty: Bool {
        return itemIdentifiers.isEmpty
    }
}

extension SelectAssetViewControllerDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if itemIdentifiers.isEmpty {
            return 2
        } else {
            return itemIdentifiers.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let itemIdentifier = itemIdentifier(for: indexPath)

        switch itemIdentifier {
        case .asset(let item):
            let cell = collectionView.dequeue(
                AssetListItemCell.self,
                at: indexPath
            )
            cell.bindData(item.viewModel)
            return cell
        case .collectibleAsset(let item):
            let cell = collectionView.dequeue(
                CollectibleListItemCell.self,
                at: indexPath
            )
            cell.bindData(item.viewModel)
            return cell
        default:
            break
        }

        return collectionView.dequeue(
            PreviewLoadingCell.self,
            at: indexPath
        )
    }
}

enum SelectAssetListItemIdentifier {
    case asset(SelectAssetListItem)
    case collectibleAsset(SelectCollectibleAssetListItem)

    var asset: Asset {
        switch self {
        case .collectibleAsset(let item): return item.asset
        case .asset(let item): return item.asset
        }
    }
}

struct SelectAssetListItem: Hashable {
    let asset: Asset
    let viewModel: SelectAssetListItemViewModel

    init(
        item: AssetItem,
        account: Account
    ) {
        self.asset = item.asset
        self.viewModel = SelectAssetListItemViewModel(
            item: item,
            account: account
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(asset.naming.name)
        hasher.combine(asset.naming.unitName)
    }

    static func == (
        lhs: SelectAssetListItem,
        rhs: SelectAssetListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.asset.naming.name == rhs.asset.naming.name &&
            lhs.asset.naming.unitName == rhs.asset.naming.unitName
    }
}

struct SelectCollectibleAssetListItem {
    let asset: Asset
    let viewModel: CollectibleListItemViewModel

    init(item: CollectibleAssetItem) {
        self.asset = item.asset
        self.viewModel = CollectibleListItemViewModel(item: item)
    }
}
