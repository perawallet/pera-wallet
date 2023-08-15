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

//   RekeyedAccountSelectionListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyedAccountSelectionListDataSource:
    UICollectionViewDiffableDataSource<RekeyedAccountSelectionListSectionIdentifier, RekeyedAccountSelectionListItemIdentifier> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<RekeyedAccountSelectionListSectionIdentifier, RekeyedAccountSelectionListItemIdentifier>

    private(set) var listHeader: RekeyedAccountSelectionListHeaderViewModel

    init(
        _ collectionView: UICollectionView,
        listHeader: RekeyedAccountSelectionListHeaderViewModel
    ) {
        self.listHeader = listHeader
        
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .account(let item):
                let cell = collectionView.dequeue(
                    RekeyedAccountSelectionListAccountCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            case .accountLoading:
                let cell = collectionView.dequeue(
                    RekeyedAccountSelectionListAccountLoadingCell.self,
                    at: indexPath
                )
                return cell
            }
        }

        supplementaryViewProvider = {
            [weak self] collectionView, kind, indexPath in
            guard let section = self?.snapshot().sectionIdentifiers[safe: indexPath.section],
                  section == .accounts,
                  kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            let header = collectionView.dequeueHeader(
                RekeyedAccountSelectionListHeader.self,
                at: indexPath
            )

            header.bindData(listHeader)

            return header
        }

        [
            RekeyedAccountSelectionListAccountLoadingCell.self,
            RekeyedAccountSelectionListAccountCell.self
        ].forEach {
            collectionView.register($0)
        }

        collectionView.register(header: RekeyedAccountSelectionListHeader.self)
    }
}
