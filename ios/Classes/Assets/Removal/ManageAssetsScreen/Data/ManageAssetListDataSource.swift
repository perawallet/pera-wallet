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

//   ManageAssetListDataSource.swift

import Foundation
import UIKit

final class ManageAssetListDataSource: UICollectionViewDiffableDataSource<ManageAssetListSection, ManageAssetListItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case let .asset(item):
                let cell = collectionView.dequeue(
                    OptOutAssetListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            case let .collectibleAsset(item):
                let cell = collectionView.dequeue(
                    OptOutCollectibleAssetListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            case .empty(let item):
                switch item {
                case .noContent:
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(AssetListSearchNoContentViewModel(hasBody: false))
                    return cell
                case .noContentSearch:
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(AssetListSearchNoContentViewModel(hasBody: true))
                    return cell
                }
            case .assetLoading:
                return collectionView.dequeue(
                    ManageAssetListLoadingCell.self,
                    at: indexPath
                )
            }
        }

        [
            OptOutAssetListItemCell.self,
            OptOutCollectibleAssetListItemCell.self,
            ManageAssetListLoadingCell.self,
            NoContentCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
