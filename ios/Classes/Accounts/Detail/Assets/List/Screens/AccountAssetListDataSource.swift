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
//   AccountAssetListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountAssetListDataSource: UICollectionViewDiffableDataSource<AccountAssetsSection, AccountAssetsItem> {
    lazy var handlers = Handlers()

    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .portfolio(item):
                let cell = collectionView.dequeue(AccountPortfolioCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case .assetManagement:
                let cell = collectionView.dequeue(AssetManagementItemCell.self, at: indexPath)
                return cell
            case let .assetTitle(item):
                let cell = collectionView.dequeue(AssetTitleItemCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case .search:
                return collectionView.dequeue(SearchBarItemCell.self, at: indexPath)
            case let .asset(item):
                let cell = collectionView.dequeue(AssetPreviewCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .pendingAsset(item):
                let cell = collectionView.dequeue(PendingAssetPreviewCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            }
        }

        [
            AccountPortfolioCell.self,
            AssetManagementItemCell.self,
            AssetTitleItemCell.self,
            SearchBarItemCell.self,
            AssetPreviewCell.self,
            PendingAssetPreviewCell.self,
        ].forEach {
            collectionView.register($0)
        }
    }
}

extension AccountAssetListDataSource: AddAssetItemViewDelegate {
    func addAssetItemViewDidTapAddAsset(_ addAssetItemView: AddAssetItemView) {
        handlers.didAddAsset?()
    }
}

extension AccountAssetListDataSource {
    struct Handlers {
        var didAddAsset: EmptyHandler?
    }
}
