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
//   AssetSearchDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetSearchDataSource: UICollectionViewDiffableDataSource<AssetSearchSection, AssetSearchItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .asset(item):
                let cell = collectionView.dequeue(AssetPreviewCell.self, at: indexPath)
                cell.bindData(item)
                return cell

            case .empty:
                let cell = collectionView.dequeue(NoContentCell.self, at: indexPath)
                cell.bindData(AssetListSearchNoContentViewModel())
                return cell
            case .noContent:
                let cell = collectionView.dequeue(NoContentCell.self, at: indexPath)
                cell.bindData(AssetListSearchNoContentViewModel(hasBody: false))
                return cell
            }
        }

        supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = AssetSearchSection(rawValue: indexPath.section),
                  section == .assets,
                  kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

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

        collectionView.register(AssetPreviewCell.self)
        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        collectionView.register(NoContentCell.self)
    }
}
