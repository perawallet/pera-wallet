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

//   CollectibleListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleListDataSource: UICollectionViewDiffableDataSource<CollectibleSection, CollectibleListItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .empty(let item):
                switch item {
                case .noContent(let item):
                    let cell = collectionView.dequeue(
                        NoContentWithActionIllustratedCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        item
                    )
                    return cell
                case .noContentSearch:
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        ReceiveCollectibleAssetListSearchNoContentViewModel()
                    )
                    return cell
                }
            case .header(let item):
                let cell = collectionView.dequeue(
                    ManagementItemWithSecondaryActionCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case .watchAccountHeader(let item):
                let cell = collectionView.dequeue(
                    ManagementItemCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case .uiActions:
                let cell = collectionView.dequeue(
                    CollectibleGalleryUIActionsCell.self,
                    at: indexPath
                )
                return cell
            case .collectibleAsset(let item):
                switch item {
                case .grid(let item):
                    let cell = collectionView.dequeue(
                        CollectibleGridItemCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        item.viewModel
                    )
                    return cell
                case .list(let item):
                    let cell = collectionView.dequeue(
                        CollectibleListItemCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        item.viewModel
                    )
                    return cell
                }
            case .pendingCollectibleAsset(let item):
                switch item {
                case .grid(let item):
                    let cell = collectionView.dequeue(
                        PendingCollectibleGridItemCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        item.viewModel
                    )
                    return cell
                case .list(let item):
                    let cell = collectionView.dequeue(
                        PendingCollectibleAssetListItemCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        item.viewModel
                    )
                    return cell
                }
            case .collectibleAssetsLoading(let item):
                switch item {
                case .grid:
                    return collectionView.dequeue(
                        CollectibleGalleryGridLoadingCell.self,
                        at: indexPath
                    )
                case .list:
                    return collectionView.dequeue(
                        CollectibleGalleryListLoadingCell.self,
                        at: indexPath
                    )
                }
            }
        }

        [
            CollectibleGridItemCell.self,
            PendingCollectibleGridItemCell.self,
            CollectibleListItemCell.self,
            PendingCollectibleAssetListItemCell.self,
            NoContentWithActionIllustratedCell.self,
            CollectibleGalleryUIActionsCell.self,
            ManagementItemWithSecondaryActionCell.self,
            ManagementItemCell.self,
            CollectibleGalleryGridLoadingCell.self,
            CollectibleGalleryListLoadingCell.self,
            NoContentCell.self,
        ].forEach {
            collectionView.register($0)
        }
    }
}
