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
            assets = account.collectibleAssets.filter(\.isOwned)
        case .standard:
            assets = account.standardAssets
        default:
            assets = account.standardAssets + account.collectibleAssets.filter(\.isOwned)
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

        let currency = sharedDataController.currency.value

        if  filter != .collectible,
            indexPath.item == .zero {
            cell.bindData(
                AssetPreviewViewModel(AssetPreviewModelAdapter.adapt((account, currency)))
            )
            return cell
        }

        guard let asset = self[indexPath] else {
            fatalError("Index path is out of bounds")
        }

        let viewModel: AssetPreviewViewModel

        if let collectibleAsset = asset as? CollectibleAsset {
            let draft = CollectibleAssetSelectionDraft(
                currency: currency,
                asset: collectibleAsset
            )
            viewModel = AssetPreviewViewModel(draft)
        } else {
            viewModel = AssetPreviewViewModel(
                AssetPreviewModelAdapter.adaptAssetSelection((asset, currency))
            )
        }

        cell.bindData(viewModel)
        return cell
    }
}
