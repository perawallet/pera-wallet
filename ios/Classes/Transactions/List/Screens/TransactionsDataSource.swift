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
//   TransactionsDataSource.swift

import UIKit
import MacaroonUIKit

final class TransactionsDataSource: UICollectionViewDiffableDataSource<TransactionsSection, TransactionsItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .algosInfo(item):
                let cell = collectionView.dequeue(AlgosDetailInfoViewCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .assetInfo(item):
                let cell = collectionView.dequeue(AssetDetailInfoViewCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .filter(item):
                let cell = collectionView.dequeue(TransactionHistoryFilterCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .title(item):
                let cell = collectionView.dequeue(TransactionHistoryTitleCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .reward(item):
                let cell = collectionView.dequeue(TransactionHistoryCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .transaction(item):
                let cell = collectionView.dequeue(TransactionHistoryCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .pending(item):
                let cell = collectionView.dequeue(PendingTransactionCell.self, at: indexPath)
                cell.bindData(item)
                cell.startAnimatingIndicator()
                return cell
            case let .empty(state):
                switch state {
                case .noContent:
                    let cell = collectionView.dequeue(NoContentCell.self, at: indexPath)
                    cell.bindData(TransactionHistoryNoContentViewModel())
                    return cell
                case .transactionHistoryLoading:
                    return collectionView.dequeue(TransactionHistoryLoadingCell.self, at: indexPath)
                case .algoTransactionHistoryLoading:
                    return collectionView.dequeue(AlgoTransactionHistoryLoadingCell.self, at: indexPath)
                case .assetTransactionHistoryLoading:
                    return collectionView.dequeue(AssetTransactionHistoryLoadingCell.self, at: indexPath)
                default:
                    return collectionView.dequeue(LoadingCell.self, at: indexPath)
                }
            case .nextList:
                return collectionView.dequeue(LoadingCell.self, at: indexPath)
            }
        }

        [
            TransactionHistoryCell.self,
            PendingTransactionCell.self,
            TransactionHistoryTitleCell.self,
            TransactionHistoryFilterCell.self,
            AlgosDetailInfoViewCell.self,
            AssetDetailInfoViewCell.self,
            NoContentCell.self,
            LoadingCell.self,
            TransactionHistoryLoadingCell.self,
            AlgoTransactionHistoryLoadingCell.self,
            AssetTransactionHistoryLoadingCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
