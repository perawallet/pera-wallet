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

//   InnerTransactionListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InnerTransactionListDataSource:
    UICollectionViewDiffableDataSource<InnerTransactionListSection, InnerTransactionListItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .header(let item):
                let cell = collectionView.dequeue(
                    InnerTransactionListTitleSupplementaryCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                return cell
            case .algoTransaction(let item):
                return Self.makeInnerTransactionPreviewCell(
                    collectionView,
                    viewModel: item.viewModel,
                    at: indexPath
                )
            case .assetTransaction(let item):
                return Self.makeInnerTransactionPreviewCell(
                    collectionView,
                    viewModel: item.viewModel,
                    at: indexPath
                )
            case .assetConfigTransaction(let item):
                return Self.makeInnerTransactionPreviewCell(
                    collectionView,
                    viewModel: item.viewModel,
                    at: indexPath
                )
            case .appCallTransaction(let item):
                return Self.makeInnerTransactionPreviewCell(
                    collectionView,
                    viewModel: item.viewModel,
                    at: indexPath
                )
            case .keyRegTransaction(let item):
                return Self.makeInnerTransactionPreviewCell(
                    collectionView,
                    viewModel: item.viewModel,
                    at: indexPath
                )
            }
        }

        [
            InnerTransactionListTitleSupplementaryCell.self,
            InnerTransactionPreviewCell.self
        ].forEach {
            collectionView.register($0)
        }
    }

    private static func makeInnerTransactionPreviewCell(
        _ collectionView: UICollectionView,
        viewModel: InnerTransactionPreviewViewModel,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(
            InnerTransactionPreviewCell.self,
            at: indexPath
        )
        cell.bindData(
            viewModel
        )
        return cell
    }
}
