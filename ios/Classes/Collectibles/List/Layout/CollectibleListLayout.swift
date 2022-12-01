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
            return insets
        case .header:
            insets.top = 28
            return insets
        case .search:
            insets.top = 16
            return insets
        case .collectibles:
            insets.top = 20
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
                return sizeForLoadingItem(
                    collectionView,
                    layout: collectionViewLayout
                )
            case .noContent(let item):
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForNoContentItem: item
                )
            case .noContentSearch:
                return sizeForSearchNoContent(
                    collectionView
                )
            }
        case .header(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item
            )
        case .watchAccountHeader(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item
            )
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
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForLoadingItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleListLoadingViewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = CollectibleListLoadingView.calculatePreferredSize(
            for: CollectibleListLoadingViewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForNoContentItem item: CollectiblesNoContentWithActionViewModel
    ) -> CGSize {
        let width = calculateContentWidth(for: listView)
        let sectionInset = collectionView(
            listView,
            layout: listViewLayout,
            insetForSectionAt: 0
        )

        let listFittingHeight =
            listView.bounds.height -
            sectionInset.vertical -
            listView.safeAreaTop -
            listView.safeAreaBottom

        let calculatedHeight = NoContentWithActionIllustratedCell.calculatePreferredSize(
            item,
            for: NoContentWithActionIllustratedCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        ).height

        return CGSize((width, max(listFittingHeight, calculatedHeight)))
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

    func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: ManagementItemViewModel
    )-> CGSize {
        let sizeCacheIdentifier = ManagementItemWithSecondaryActionCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = ManagementItemWithSecondaryActionCell.calculatePreferredSize(
            item,
            for: ManagementItemWithSecondaryActionCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleItem item: CollectibleCellItem
    ) -> CGSize {
        switch item {
        case let .pending(item),
            let .owner(item),
            let .optedIn(item):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForCollectibleItem: item.viewModel
            )
        }
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleItem item: CollectibleListItemViewModel
    ) -> CGSize {
        let width = calculateGridCellWidth(listView, layout: listViewLayout)

        let newSize = CollectibleListItemCell.calculatePreferredSize(
            item,
            for: CollectibleListItemCell.theme,
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
