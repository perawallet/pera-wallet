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

    var galleryUIStyle: CollectibleGalleryUIStyle

    init(
        listDataSource: CollectibleListDataSource,
        galleryUIStyle: CollectibleGalleryUIStyle
    ) {
        self.listDataSource = listDataSource
        self.galleryUIStyle = galleryUIStyle
        super.init()
    }
    
    static var listFlowLayout: UICollectionViewFlowLayout {
        let flowLayout = CollectionViewSwitchableFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }

    static var gridFlowLayout: UICollectionViewFlowLayout {
        let flowLayout = TopAlignedCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
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
        case .header:
            insets.top = 28
            return insets
        case .uiActions:
            insets.top = 16
            return insets
        case .collectibles:
            return insetForSectionCollectiblesSection(
                collectionView,
                layout: collectionViewLayout
            )
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
            case .noContent(let item):
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForNoContentItem: item,
                    atSection: indexPath.section
                )
            case .noContentSearch:
                return sizeForSearchNoContent(
                    collectionView,
                    atSection: indexPath.section
                )
            }
        case .header(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item,
                atSection: indexPath.section
            )
        case .watchAccountHeader(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item,
                atSection: indexPath.section
            )
        case .uiActions:
            return sizeForUIActions(
                collectionView,
                layout: collectionViewLayout,
                atSection: indexPath.section
            )
        case .collectibleAsset(let item):
            switch item {
            case .grid(let item):
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForCollectibleGridItem: item.viewModel
                )
            case .list(let item):
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForCollectibleListItem: item.viewModel,
                    atSection: indexPath.section
                )
            }
        case .pendingCollectibleAsset(let item):
            switch item {
            case .grid(let item):
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForCollectibleGridItem: item.viewModel
                )
            case .list(let item):
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForPendingCollectibleAssetCellItem: item.viewModel,
                    atSection: indexPath.section
                )
            }
        case .collectibleAssetsLoading(let item):
            switch item {
            case .grid:
                return sizeForCollectibleAssetsLoadingGridItem(
                    collectionView,
                    layout: collectionViewLayout,
                    atSection: indexPath.section
                )
            case .list:
                return sizeForCollectibleAssetsLoadingListItem(
                    collectionView,
                    layout: collectionViewLayout,
                    atSection: indexPath.section
                )
            }
        }
    }
}

extension CollectibleListLayout {
    private func insetForSectionCollectiblesSection(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout
    ) -> UIEdgeInsets {
        if galleryUIStyle.isGrid {
            return UIEdgeInsets((28, sectionHorizontalInsets.leading, 8, sectionHorizontalInsets.trailing))
        } else {
            return UIEdgeInsets((16, 0, 8, 0))
        }
    }
}

extension CollectibleListLayout {
    private func sizeForSearchNoContent(
        _ listView: UICollectionView,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let item = ReceiveCollectibleAssetListSearchNoContentViewModel()
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForCollectibleAssetsLoadingGridItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleGalleryGridLoadingCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = CollectibleGalleryGridLoadingCell.calculatePreferredSize(
            for: CollectibleGalleryGridLoadingCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForCollectibleAssetsLoadingListItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleGalleryListLoadingCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = CollectibleGalleryListLoadingCell.calculatePreferredSize(
            for: CollectibleGalleryListLoadingCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForNoContentItem item: CollectiblesNoContentWithActionViewModel,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
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

    private func sizeForUIActions(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleGalleryUIActionsCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = CollectibleGalleryUIActionsCell.calculatePreferredSize(
            for: CollectibleGalleryUIActionsCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: ManagementItemViewModel,
        atSection section: Int
    )-> CGSize {
        let sizeCacheIdentifier = ManagementItemWithSecondaryActionCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
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
        sizeForCollectibleGridItem item: CollectibleGridItemViewModel
    ) -> CGSize {
        let width = calculateGridItemCellWidth(
            listView,
            layout: listViewLayout
        )

        let newSize = CollectibleGridItemCell.calculatePreferredSize(
            item,
            for: CollectibleGridItemCell.theme,
            fittingIn: CGSize(width: width.float(), height: .greatestFiniteMagnitude)
        )

        return newSize
    }
}

extension CollectibleListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleListItem item: CollectibleListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = CollectibleListItemCell.calculatePreferredSize(
            item,
            for: CollectibleListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPendingCollectibleAssetCellItem item: CollectibleListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = PendingCollectibleAssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = PendingCollectibleAssetListItemCell.calculatePreferredSize(
            item,
            for: PendingCollectibleAssetListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension CollectibleListLayout {
    func calculateGridItemCellWidth(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) ->  LayoutMetric {
        let column = 2

        let flowLayout = listViewLayout as! UICollectionViewFlowLayout
        let contentWidth =
            listView.bounds.width -
            listView.contentInset.horizontal -
            sectionHorizontalInsets.leading -
            sectionHorizontalInsets.trailing
        let rowSpacing = flowLayout.minimumInteritemSpacing * CGFloat(column - 1)
        let width = (contentWidth - rowSpacing)  / column.cgFloat

        return width
    }

    private func calculateContentWidth(
        _ collectionView: UICollectionView,
        forSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = self.collectionView(
            collectionView,
            layout: collectionView.collectionViewLayout,
            insetForSectionAt: section
        )
        return
            collectionView.bounds.width -
            collectionView.contentInset.horizontal -
            sectionInset.left -
            sectionInset.right
    }
}
