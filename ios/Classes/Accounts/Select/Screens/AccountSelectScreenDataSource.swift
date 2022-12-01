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

//   AccountSelectScreenDataSource.swift

import Foundation
import Foundation
import MacaroonUIKit
import UIKit

final class AccountSelectScreenDataSource: UICollectionViewDiffableDataSource<AccountSelectSection, AccountSelectItem> {
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
                        LoadingCell.self,
                        at: indexPath
                    )
                case .noContent:
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        AccountSelectNoContentViewModel(hasBody: true)
                    )
                    return cell
                }
            case .account(let item):
                switch item {
                case .header(let viewModel):
                    let header = collectionView.dequeue(
                        TitleHeaderCell.self,
                        at: indexPath
                    )
                    header.bindData(viewModel)
                    return header
                case .accountCell(let viewModel), .searchAccountCell(let viewModel), .matchedAccountCell(let viewModel):
                    let cell = collectionView.dequeue(
                        AccountListItemCell.self,
                        at: indexPath
                    )
                    cell.bindData(viewModel)
                    return cell
                case .contactCell(let viewModel):
                    let cell = collectionView.dequeue(
                        SelectContactCell.self,
                        at: indexPath
                    )
                    cell.bindData(viewModel)
                    return cell
                }
            }
        }

        [
            TitleHeaderCell.self,
            NoContentCell.self,
            LoadingCell.self,
            AccountListItemCell.self,
            SelectContactCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
