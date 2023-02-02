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

//   ReceiveCollectibleAccountListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ReceiveCollectibleAssetListDataSource:
    UICollectionViewDiffableDataSource<ReceiveCollectibleAssetListSection, ReceiveCollectibleAssetListItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .empty(let item):
                switch item {
                case .loading:
                    return collectionView.dequeue(
                        CollectibleListItemLoadingCell.self,
                        at: indexPath
                    )
                case .noContent:
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        ReceiveCollectibleAssetListSearchNoContentViewModel()
                    )
                    return cell
                }
            case .info:
                let cell = collectionView.dequeue(
                    ReceiveCollectibleInfoBoxCell.self,
                    at: indexPath
                )
                cell.bindData(
                    ReceiveCollectibleAssetListInfoViewModel()
                )
                return cell
            case .search:
                let cell = collectionView.dequeue(CollectibleReceiveSearchInputCell.self, at: indexPath)
                return cell
            case .collectible(let item):
                let cell = collectionView.dequeue(
                    OptInAssetListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            }
        }

        [
            CollectibleListItemLoadingCell.self,
            NoContentCell.self,
            OptInAssetListItemCell.self,
            ReceiveCollectibleInfoBoxCell.self,
            CollectibleReceiveSearchInputCell.self,
        ].forEach {
            collectionView.register($0)
        }
    }
}
