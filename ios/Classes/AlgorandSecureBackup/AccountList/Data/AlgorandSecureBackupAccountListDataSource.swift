// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupAccountListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupAccountListDataSource:
    UICollectionViewDiffableDataSource<AlgorandSecureBackupAccountListSectionIdentifier, AlgorandSecureBackupAccountListItemIdentifier> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AlgorandSecureBackupAccountListSectionIdentifier, AlgorandSecureBackupAccountListItemIdentifier>

    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .account(let item):
                switch item {
                case .header(let headerItem):
                    let cell = collectionView.dequeue(
                        AlgorandSecureBackupAccountListAccountsHeader.self,
                        at: indexPath
                    )
                    cell.bindData(headerItem)
                    return cell
                case .cell(let cellItem):
                    let cell = collectionView.dequeue(
                        AlgorandSecureBackupAccountListAccountCell.self,
                        at: indexPath
                    )
                    cell.bindData(cellItem.viewModel)
                    return cell
                }
            case .noContent:
                let cell = collectionView.dequeue(
                    NoContentCell.self,
                    at: indexPath
                )
                cell.bindData(AlgorandSecureBackupNoAccountCellViewModel())
                return cell
            }
        }

        [
            AlgorandSecureBackupAccountListAccountsHeader.self,
            AlgorandSecureBackupAccountListAccountCell.self,
            NoContentCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
