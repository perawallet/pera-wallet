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
    var isEmpty: Bool {
        return items.isEmpty
    }

    private lazy var currencyFormatter = CurrencyFormatter()

    private var items: [SelectAssetListItem] = []

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
    
    subscript(indexPath: IndexPath) -> SelectAssetListItem? {
        return items[safe: indexPath.item]
    }
}

extension SelectAssetViewControllerDataSource {
    func loadData(completion: @escaping () -> Void) {
        asyncBackground {
            [weak self] in
            guard let self = self else { return }

            var items: [SelectAssetListItem] = []

            let algoItem = self.makeAssetItem(self.account.algo)
            items.append(algoItem)

            for blockchainAsset in self.account.assets.someArray {
                let asset = self.account[blockchainAsset.id]

                switch asset {
                case let standardAsset as StandardAsset:
                    let assetItem = self.makeAssetItem(standardAsset)
                    items.append(assetItem)
                case let collectibleAsset as CollectibleAsset where collectibleAsset.isOwned:
                    let assetItem = self.makeAssetItem(collectibleAsset)
                    items.append(assetItem)
                default:
                    break
                }
            }

            self.items = items

            asyncMain(execute: completion)
        }
    }

    private func makeAssetItem(_ asset: Asset) -> SelectAssetListItem {
        let item = AssetItem(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter,
            currencyFormattingContext: .listItem
        )
        return SelectAssetListItem(item: item, account: account)
    }
}

extension SelectAssetViewControllerDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if items.isEmpty {
            return 2
        } else {
            return items.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let item = self[indexPath] {
            let cell = collectionView.dequeue(
                AssetListItemCell.self,
                at: indexPath
            )
            cell.bindData(item.viewModel)
            return cell
        } else {
            return collectionView.dequeue(
                PreviewLoadingCell.self,
                at: indexPath
            )
        }
    }
}

struct SelectAssetListItem: Hashable {
    let model: Asset
    let viewModel: SelectAssetListItemViewModel

    init(
        item: AssetItem,
        account: Account
    ) {
        self.model = item.asset
        self.viewModel = SelectAssetListItemViewModel(
            item: item,
            account: account
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
        hasher.combine(model.naming.name)
        hasher.combine(model.naming.unitName)
    }

    static func == (
        lhs: SelectAssetListItem,
        rhs: SelectAssetListItem
    ) -> Bool {
        return
            lhs.model.id == rhs.model.id &&
            lhs.model.naming.name == rhs.model.naming.name &&
            lhs.model.naming.unitName == rhs.model.naming.unitName
    }
}
