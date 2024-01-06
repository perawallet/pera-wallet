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

//   WebImportSuccessScreenDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WebImportSuccessScreenDataSource: UICollectionViewDiffableDataSource<WebImportSuccessListViewSection, WebImportSuccessListViewItem> {
    init(
        _ collectionView: UICollectionView,
        dataController: WebImportSuccessScreenDataController
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .account(let item):
                let cell = collectionView.dequeue(
                    AccountListItemCell.self,
                    at: indexPath
                )
                cell.bindData(
                    dataController.accountListItemViewModel(for: item.accountAddress)
                )
                return cell
            case .header(let item):
                let cell = collectionView.dequeue(
                    WebImportSuccessHeaderView.self,
                    at: indexPath
                )
                cell.bindData(
                    WebImportSuccessHeaderViewModel(
                        importedAccountCount: item.importedAccountCount
                    )
                )
                return cell
            case .asbHeader(let item):
                let cell = collectionView.dequeue(
                    WebImportSuccessHeaderView.self,
                    at: indexPath
                )
                cell.bindData(
                    AlgorandSecureBackupImportSuccessHeaderViewModel(
                        importedAccountCount: item.importedAccountCount
                    )
                )
                return cell
            case .missingAccounts(let item):
                let cell = collectionView.dequeue(
                    WebImportSuccessInfoBoxCell.self,
                    at: indexPath
                )
                cell.bindData(
                    WebImportSuccessInfoBoxViewModel(
                        unimportedAccountCount: item.unimportedAccountCount
                    )
                )
                return cell
            case .asbMissingAccounts(let item):
                let cell = collectionView.dequeue(
                    WebImportSuccessInfoBoxCell.self,
                    at: indexPath
                )
                cell.bindData(
                    AlgorandSecureBackupImportSuccessInfoBoxViewModel(
                        unimportedAccountCount: item.unimportedAccountCount,
                        unsupportedAccountCount: item.unsupportedAccountCount
                    )
                )
                return cell
            }
        }

        [
            WebImportSuccessInfoBoxCell.self,
            AccountListItemCell.self,
            WebImportSuccessHeaderView.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
