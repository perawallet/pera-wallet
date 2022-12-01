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

//   SelectAssetDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SelectAssetDataSource: UICollectionViewDiffableDataSource<SelectAssetSection, SelectAssetItem> {
    var isEmpty: Bool {
        return snapshot().sectionIdentifiers.contains {
            $0 == .empty || $0 == .error
        }
    }

    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .asset(item):
                let cell = collectionView.dequeue(SelectAssetListItemCell.self, at: indexPath)
                cell.bindData(item.viewModel)
                return cell
            case .empty(let item):
                switch item {
                case .loading:
                    return collectionView.dequeue(
                        PreviewLoadingCell.self,
                        at: indexPath
                    )
                case .noContent(let viewModel):
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(viewModel)
                    return cell
                }
            case .error(let viewModel):
                let cell = collectionView.dequeue(
                    NoContentCell.self,
                    at: indexPath
                )
                cell.bindData(viewModel)
                return cell
            }
        }

        [
            SelectAssetListItemCell.self,
            NoContentCell.self,
            PreviewLoadingCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
