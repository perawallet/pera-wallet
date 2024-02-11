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

//   MeldAccountSelectionListLayout.swift

import Foundation
import UIKit
import MacaroonUIKit

final class MeldAccountSelectionListLayout: AccountSelectionListLayout {
    typealias ListDataSource = MeldAccountSelectionListDataSource.DataSource

    private var sizeCache: [String: CGSize] = [:]

    private unowned let listDataSource: ListDataSource
    private unowned let itemDataSource: MeldAccountSelectionListItemDataSource

    init(
        dataSource: ListDataSource,
        itemDataSource: MeldAccountSelectionListItemDataSource
    ) {
        self.listDataSource = dataSource
        self.itemDataSource = itemDataSource
    }

    static func build() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        return flowLayout
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let snapshot = listDataSource.snapshot()
        let sectionIdentifiers = snapshot.sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .empty:
            return .zero
        case .accounts,
             .loading:
            return UIEdgeInsets(
                top: 24,
                left: .zero,
                bottom: 8,
                right: .zero
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listView(
            collectionView,
            sizeForHeaderItem: itemDataSource.headerItem,
            atSection: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return .zero
        }

        switch itemIdentifier {
        case .loading:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountCellItem: nil,
                atSection: indexPath.section
            )
        case .empty(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForEmptyItem: item,
                atSection: indexPath.section
            )
        case .account(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountCellItem: itemDataSource.accountItems[item.accountAddress]!,
                atSection: indexPath.section
            )
        }
    }
}

extension MeldAccountSelectionListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: MeldAccountSelectionListEmptyItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        )
        let sectionInset = collectionView(
            listView,
            layout: listViewLayout,
            insetForSectionAt: section
        )
        let headerSize = collectionView(
            listView,
            layout: listViewLayout,
            referenceSizeForHeaderInSection: section
        )
        let height =
            listView.bounds.height -
            listView.contentInset.top -
            headerSize.height -
            sectionInset.vertical -
            listView.safeAreaTop -
            listView.safeAreaBottom
        return CGSize((width, height))
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItem item: AccountListItemViewModel?,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = MeldAccountSelectionListAccountListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = MeldAccountSelectionListAccountListItemCell.calculatePreferredSize(
            sampleAccountItem,
            for: MeldAccountSelectionListAccountListItemCell.theme.context,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        sizeForHeaderItem item: MeldAccountSelectionListHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = MeldAccountSelectionListHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        )
        let newSize = MeldAccountSelectionListHeader.calculatePreferredSize(
            item,
            for: MeldAccountSelectionListHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension MeldAccountSelectionListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView,
        forSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = self.collectionView(
            listView,
            layout: listView.collectionViewLayout,
            insetForSectionAt: section
        )
        return
            listView.bounds.width -
            listView.contentInset.horizontal -
            sectionInset.left -
            sectionInset.right
    }
}
