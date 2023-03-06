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

//   ReceiverAccountSelectionListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ReceiverAccountSelectionListDataSource:
    UICollectionViewDiffableDataSource<ReceiverAccountSelectionListSection, ReceiverAccountSelectionListItem> {
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
                        PreviewLoadingCell.self,
                        at: indexPath
                    )
                case .noContent:
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        ReceiverAccountSelectionNoContentViewModel()
                    )
                    return cell
                }
            case .header(let item):
                let cell = collectionView.dequeue(
                    ReceiverAccountSelectionListTitleSupplementaryCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                return cell
            case .account(let item, let isPreviouslySelected):
                let cell = collectionView.dequeue(
                    ReceiverAccountSelectionPreviewCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                cell.isPreviouslySelected = isPreviouslySelected
                return cell
            case .accountGeneratedFromQuery(let item, let isPreviouslySelected):
                let cell = collectionView.dequeue(
                    ReceiverAccountSelectionPreviewCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                cell.isPreviouslySelected = isPreviouslySelected
                return cell
            case .contact(let item, let isPreviouslySelected):
                let cell = collectionView.dequeue(
                    ReceiverAccountSelectionListContactCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                cell.isPreviouslySelected = isPreviouslySelected
                return cell
            case .nameServiceAccount(let item, let isPreviouslySelected):
                let cell = collectionView.dequeue(
                    ReceiverAccountSelectionPreviewCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                cell.isPreviouslySelected = isPreviouslySelected
                return cell
            }
        }

        [
            PreviewLoadingCell.self,
            NoContentCell.self,
            ReceiverAccountSelectionListTitleSupplementaryCell.self,
            ReceiverAccountSelectionPreviewCell.self,
            ReceiverAccountSelectionListContactCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
