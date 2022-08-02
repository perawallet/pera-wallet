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

final class SelectAssetViewControllerDataSource:
    NSObject,
    UICollectionViewDataSource {
    private lazy var currencyFormatter = CurrencyFormatter()

    private let sharedDataController: SharedDataController
    private let account: Account

    private let filter: AssetType?
    private let assets: [Asset]

    init(
        filter: AssetType?,
        account: Account,
        sharedDataController: SharedDataController
    ) {
        self.filter = filter
        self.account = account
        self.sharedDataController = sharedDataController

        switch filter {
        case .collectible:
            assets = account.collectibleAssets.someArray.filter(\.isOwned)
        case .standard:
            assets = account.standardAssets.someArray
        default:
            assets = account.standardAssets.someArray + account.collectibleAssets.someArray.filter(\.isOwned)
        }

        super.init()
    }
    
    subscript(indexPath: IndexPath) -> Asset? {
        switch filter {
        case .collectible:
            return assets[safe: indexPath.item]
        default:
            return assets[safe: indexPath.item.advanced(by: -1)]
        }
    }
}

extension SelectAssetViewControllerDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch filter {
        case .collectible:
            return assets.count
        default:
            return assets.count.advanced(by: 1)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AssetPreviewCell.self, at: indexPath)

        let currency = sharedDataController.currency

        if  filter != .collectible,
            indexPath.item == .zero {
            let algoAssetItem = AlgoAssetItem(
                account: account,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            let preview = AssetPreviewModelAdapter.adapt(algoAssetItem)
            let previewViewModel = AssetPreviewViewModel(preview)

            cell.bindData(previewViewModel)

            return cell
        }

        guard let asset = self[indexPath] else {
            fatalError("Index path is out of bounds")
        }

        if let collectibleAsset = asset as? CollectibleAsset {
            let draft = CollectibleAssetPreviewSelectionDraft(
                asset: collectibleAsset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            let viewModel = AssetPreviewViewModel(draft)

            cell.bindData(viewModel)

            return cell
        }

        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let preview = AssetPreviewModelAdapter.adaptAssetSelection(assetItem)
        let previewViewModel = AssetPreviewViewModel(preview)

        cell.bindData(previewViewModel)

        return cell
    }
}
