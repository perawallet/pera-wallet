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

        supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = AccountAssetsSection(rawValue: indexPath.section),
                  section == .assets else {
                return nil
            }

            if kind == UICollectionView.elementKindSectionHeader {
                let view = collectionView.dequeueHeader(SingleLineTitleActionHeaderView.self, at: indexPath)
                view.bindData(
                    SingleLineTitleActionViewModel(
                        item: SingleLineIconTitleItem(
                            icon: nil,
                            title: .string("accounts-title-assets".localized)
                        )
                    )
                )
                return view
            }

            let view = collectionView.dequeueFooter(AddAssetItemFooterView.self, at: indexPath)
            view.delegate = self
            return view
        }

        [
            AccountPortfolioCell.self,
            SearchBarItemCell.self,
            AssetPreviewCell.self,
            PendingAssetPreviewCell.self
        ].forEach {
            collectionView.register($0)
        }

        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        collectionView.register(footer: AddAssetItemFooterView.self)
    }
}

extension AccountAssetListDataSource: AddAssetItemFooterViewDelegate {
    func addAssetItemFooterViewDidTapAddAsset(_ addAssetItemFooterView: AddAssetItemFooterView) {
        handlers.didAddAsset?()
    }
}

extension AccountAssetListDataSource {
    struct Handlers {
        var didAddAsset: EmptyHandler?
    }
}
