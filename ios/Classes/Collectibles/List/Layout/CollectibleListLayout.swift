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

//   CollectibleListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: CollectibleListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    init(
        listDataSource: CollectibleListDataSource
    ) {
        self.listDataSource = listDataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = TopAlignedCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 28
        flowLayout.minimumInteritemSpacing = 24
        return flowLayout
    }
}

extension CollectibleListLayout {
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
        case .empty:
            return insets
        case .loading:
            insets.bottom = 8
            return insets
        case .search:
            insets.top = 20
            return insets
        case .collectibles:
            insets.top = 24
            insets.bottom = 8
            return insets
        }
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
        case .empty(let item):
            switch item {
            case .loading:
                return sizeForEmptyItem(
                    collectionView,
                    layout: collectionViewLayout,
                    atSection: indexPath.section
                )
            case .noContent:
                return sizeForEmptyItem(
                    collectionView,
                    layout: collectionViewLayout,
                    atSection: indexPath.section
                )
            case .noContentSearch:
                return sizeForSearchNoContent(
                    collectionView
                )
            }
        case .search:
            return sizeForSearch(
                collectionView,
                layout: collectionViewLayout
            )
        case .collectible(let item):
            switch item {
            case .cell(let item):
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForCollectibleItem: item
                )
            case .footer:
                return sizeForFooter(
                    collectionView,
                    layout: collectionViewLayout
                )
            }
        }
    }
}

extension CollectibleListLayout {
    private func sizeForSearchNoContent(
        _ listView: UICollectionView
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let item = ReceiveCollectibleAssetListSearchNoContentViewModel()
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn:  CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForEmptyItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(for: listView)
        let sectionInset = collectionView(
            listView,
            layout: listViewLayout,
            insetForSectionAt: section
        )
        let height =
            listView.bounds.height -
            sectionInset.vertical -
            listView.safeAreaTop -
            listView.safeAreaBottom
        return CGSize((width, height))
    }

    private func sizeForSearch(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleListSearchInputCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let height: LayoutMetric = 40
        let newSize = CGSize((width, height))

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForFooter(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleListItemReceiveCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateGridCellWidth(listView, layout: listViewLayout)

        let newSize = CGSize(width: width.float(), height: width.float())

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleItem item: CollectibleCellItem
    ) -> CGSize {
        switch item {
        case let .owner(item),
             let .optedIn(item):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForCollectibleReadyCellItem: item.viewModel
            )
        case .pending(let item):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForCollectiblePendingCellItem: item.viewModel
            )
        }
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleReadyCellItem item: CollectibleListItemReadyViewModel
    ) -> CGSize {
        let width = calculateGridCellWidth(listView, layout: listViewLayout)

        let newSize = CollectibleListItemCell.calculatePreferredSize(
            item,
            for: CollectibleListItemCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectiblePendingCellItem item: CollectibleListItemPendingViewModel
    ) -> CGSize {
        let width = calculateGridCellWidth(listView, layout: listViewLayout)

        let newSize = CollectibleListItemPendingCell.calculatePreferredSize(
            item,
            for: CollectibleListItemPendingCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )

        return newSize
    }
}

extension CollectibleListLayout {
    func calculateGridCellWidth(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) ->  LayoutMetric {
        let column = 2

        let flowLayout = listViewLayout as! UICollectionViewFlowLayout
        let contentWidth = calculateContentWidth(for: listView)
        let rowSpacing = flowLayout.minimumInteritemSpacing * CGFloat(column - 1)
        let width = (contentWidth - rowSpacing)  / column.cgFloat

        return width
    }

    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        sectionHorizontalInsets.leading -
        sectionHorizontalInsets.trailing
    }
}
