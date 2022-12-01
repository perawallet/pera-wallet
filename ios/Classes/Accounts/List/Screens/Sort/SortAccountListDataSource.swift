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

//   SortAccountListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

/// <todo>
/// Switch to new reordering API (iOS 14)
final class SortAccountListDataSource:
    UICollectionViewDiffableDataSource<SortAccountListSection, SortAccountListItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SortAccountListSection, SortAccountListItem>

    weak var dataController: SortAccountListDataController?

    init(
        _ collectionView: UICollectionView,
        dataController: SortAccountListDataController
    ) {
        self.dataController = dataController
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .sortOption(let item):
                let cell = collectionView.dequeue(
                    SingleSelectionCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item.value
                )
                return cell
            case .reordering(let item):
                let cell = collectionView.dequeue(
                    AccountOrderingListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            }
        }

        supplementaryViewProvider = {
            [weak self] collectionView, kind, indexPath in
            guard let section = self?.snapshot().sectionIdentifiers[safe: indexPath.section],
                  section == .reordering,
                  kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            let header = collectionView.dequeueHeader(
                SortAccountListTitleSupplementaryHeader.self,
                at: indexPath
            )

            header.bindData(
                SortAccountListOrderTitleViewModel()
            )

            return header
        }

        [
            SingleSelectionCell.self,
            AccountOrderingListItemCell.self
        ].forEach {
            collectionView.register($0)
        }

        collectionView.register(
            header: SortAccountListTitleSupplementaryHeader.self
        )
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        canMoveItemAt indexPath: IndexPath
    ) -> Bool {
        let sectionIdentifiers = snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return false
        }

        return listSection == .reordering
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        dataController?.moveItem(
            from: sourceIndexPath,
            to: destinationIndexPath
        )

        moveItem(
            from: sourceIndexPath,
            to: destinationIndexPath
        )
    }
}

extension SortAccountListDataSource {
    private func moveItem(
        from source: IndexPath,
        to destination: IndexPath
    ) {
        if source == destination {
            return
        }

        let snapshot = makeSnapshot(
            movingItemFrom: source,
            to: destination
        )
        apply(
            snapshot,
            animatingDifferences: false
        )
    }

    private func makeSnapshot(
        movingItemFrom source: IndexPath,
        to destination: IndexPath
    ) -> Snapshot {
        var snapshot = snapshot()

        guard
            let sourceItem = itemIdentifier(for: source),
            let destinationItem = itemIdentifier(for: destination)
        else {
            return snapshot
        }

        if source > destination {
            snapshot.moveItem(
                sourceItem,
                beforeItem: destinationItem
            )
        } else {
            snapshot.moveItem(
                sourceItem,
                afterItem: destinationItem
            )
        }

        return snapshot
    }
}
