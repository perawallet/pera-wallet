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

//   SortAccountListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SortAccountListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: SortAccountListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)
    
    init(
        listDataSource: SortAccountListDataSource
    ) {
        self.listDataSource = listDataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension SortAccountListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        var insets = UIEdgeInsets(
            (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
        )

        switch listSection {
        case .sortOptions:
            insets.top = 20
            insets.bottom = 8
            return insets
        case .reordering:
            insets.left = 0
            insets.right = 0
            insets.bottom = 8
            return insets
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section],
              listSection == .reordering else {
            return .zero
        }

        return 4
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section],
              listSection == .reordering else {
            return CGSize((collectionView.bounds.width, 0))
        }

        let size = listView(
            collectionView,
            sizeForHeaderItem: SortAccountListOrderTitleViewModel()
        )
        return size
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .sortOption:
            return sizeForSingleSelectionCell(
                collectionView,
                layout: collectionViewLayout
            )
        case .reordering(let item):
            let size = listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountCellItem: item
            )
            return size
        }
    }
}

extension SortAccountListLayout {
    private func sizeForSingleSelectionCell(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let sizeCacheIdentifier = SingleSelectionCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)

        let newSize = CGSize(
            width: width,
            height: 56 /// <todo>: Calculate height
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItem item: AccountListItemViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = AccountListItemCell.reuseIdentifier

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
        let newSize = AccountListItemCell.calculatePreferredSize(
            sampleAccountItem,
            for: AccountListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        sizeForHeaderItem item: SortAccountListOrderTitleViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = SortAccountListTitleSupplementaryHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = TitleView.calculatePreferredSize(
            item,
            for: SortAccountListTitleSupplementaryHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension SortAccountListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
            listView.contentInset.horizontal -
            sectionHorizontalInsets.leading -
            sectionHorizontalInsets.trailing
    }
}
