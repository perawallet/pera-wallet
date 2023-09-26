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
//   AssetListViewDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetListViewDataSource: UICollectionViewDiffableDataSource<
    OptInAssetList.SectionIdentifier,
    OptInAssetList.ItemIdentifier
> {
    init(
        collectionView: UICollectionView,
        dataController: AssetListViewDataController
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .loading:
                return Self.listView(
                    collectionView,
                    cellForLoadingItemAt: indexPath
                )
            case .loadingFailed(let item):
                return Self.listView(
                    collectionView,
                    cellForLoadingFailedItem: item,
                    at: indexPath
                )
            case .notFound:
                return Self.listView(
                    collectionView,
                    cellForNotFoundItemAt: indexPath
                )
            case .asset(let item):
                let viewModel: OptInAssetListItemViewModel? = dataController[item.assetID]
                return Self.listView(
                    collectionView,
                    cellForAssetItemWith: viewModel,
                    at: indexPath
                )
            case .loadingMore:
                return Self.listView(
                    collectionView,
                    cellForLoadingMoreItemAt: indexPath
                )
            case .loadingMoreFailed(let item):
                return Self.listView(
                    collectionView,
                    cellForLoadingMoreFailedItem: item,
                    at: indexPath
                )
            }
        }

        prepareForUse(collectionView)
    }
}

extension AssetListViewDataSource {
    private func prepareForUse(_ listView: UICollectionView) {
        let cells = [
            OptInAssetListLoadingCell.self,
            NoContentWithActionCell.self,
            NoContentCell.self,
            OptInAssetListItemCell.self,
            OptInAssetNextListLoadingCell.self
        ]
        cells.forEach {
            listView.register($0)
        }
    }
}

extension AssetListViewDataSource {
    private static func listView(
        _ listView: UICollectionView,
        cellForLoadingItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return listView.dequeue(
            OptInAssetListLoadingCell.self,
            at: indexPath
        )
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForLoadingFailedItem item: OptInAssetList.ErrorItem,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = OptInAssetListErrorViewModel(error: item)
        let cell = listView.dequeue(
            NoContentWithActionCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForNotFoundItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = OptInAssetListNotFoundViewModel()
        let cell = listView.dequeue(
            NoContentCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForAssetItemWith viewModel: OptInAssetListItemViewModel?,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = listView.dequeue(
            OptInAssetListItemCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForLoadingMoreItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return listView.dequeue(
            OptInAssetNextListLoadingCell.self,
            at: indexPath
        )
    }

    private static func listView(
        _ listView: UICollectionView,
        cellForLoadingMoreFailedItem item: OptInAssetList.ErrorItem,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = OptInAssetNextListErrorViewModel(error: item)
        let cell = listView.dequeue(
            NoContentWithActionCell.self,
            at: indexPath
        )
        cell.bindData(viewModel)
        return cell
    }
}
