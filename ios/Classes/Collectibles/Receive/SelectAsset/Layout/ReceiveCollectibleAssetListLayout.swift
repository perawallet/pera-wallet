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

//   ReceiveCollectibleAssetListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ReceiveCollectibleAssetListLayout: NSObject {
    private var insetCache: [ReceiveCollectibleAssetListSection: UIEdgeInsets] = [:]
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: ReceiveCollectibleAssetListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    var selectedAccountPreviewCanvasViewHeight: LayoutMetric = 0

    init(
        listDataSource: ReceiveCollectibleAssetListDataSource
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

extension ReceiveCollectibleAssetListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        return listView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: listSection
        )
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
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForAssetCellItem: nil
                )
            case .noContent:
                return sizeForSearchNoContent(
                    collectionView
                )
            }
        case .info:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForInfoItem: .init()
            )
        case .search:
            return sizeForSearch(
                collectionView,
                layout: collectionViewLayout
            )
        case .collectible(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetCellItem: item
            )
        }
    }

    func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForInfoItem item: ReceiveCollectibleAssetListInfoViewModel
    )-> CGSize {
        let sizeCacheIdentifier = InfoCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = InfoCell.calculatePreferredSize(
            item,
            for: InfoCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    func sizeForSearch(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleReceiveSearchInputCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let height: LayoutMetric = 40
        let newSize = CGSize((width, height))

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension ReceiveCollectibleAssetListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        insetForSectionAt section: ReceiveCollectibleAssetListSection
    ) -> UIEdgeInsets {
        if let insetCache = insetCache[section] {
            return insetCache
        }

        var insets = UIEdgeInsets(
            (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
        )

        switch section {
        case .empty:
            break
        case .loading:
            let infoHeight = self.listView(
                listView,
                layout: listViewLayout,
                sizeForInfoItem: .init()
            ).height
            let infoSectionVerticalInsets = self.listView(
                listView,
                layout: listViewLayout,
                insetForSectionAt: .info
            ).vertical
            let searchHeight = sizeForSearch(
                listView,
                layout: listViewLayout
            ).height
            let searchSectionVerticalInsets = self.listView(
                listView,
                layout: listViewLayout,
                insetForSectionAt: .search
            ).vertical
            let collectiblesSectionTopInset = self.listView(
                listView,
                layout: listViewLayout,
                insetForSectionAt: .collectibles
            ).top
            let topInset =
            infoHeight +
            infoSectionVerticalInsets +
            searchHeight +
            searchSectionVerticalInsets +
            collectiblesSectionTopInset +
            CollectibleListItemCell.contextPaddings.top

            insets.top = topInset
            insets.bottom = 8
        case .info:
            insets.top = 12
        case .search:
            insets.top = 20
        case .collectibles:
            insets.top = 16
            let defaultAdditionalBottomInset: LayoutMetric = 8

            let bottomInset =
            defaultAdditionalBottomInset +
            selectedAccountPreviewCanvasViewHeight -
            listView.safeAreaBottom

            insets.bottom = bottomInset
        }

        insetCache[section] = insets

        return insets
    }

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

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetCellItem item: AssetPreviewViewModel?
    ) -> CGSize {
        let sizeCacheIdentifier = AssetPreviewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)

        let sampleAssetPreview = AssetPreviewModel(
            icon: .algo,
            verifiedIcon: img("icon-verified-shield"),
            title: "title-unknown".localized,
            subtitle: "title-unknown".localized,
            primaryAccessory: "title-unknown".localized,
            secondaryAccessory: "title-unknown".localized,
            currencyAmount: 0,
            asset: nil
        )

        let sampleAssetItem = AssetPreviewViewModel(sampleAssetPreview)

        let newSize = AssetPreviewCell.calculatePreferredSize(
            sampleAssetItem,
            for: AssetPreviewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension ReceiveCollectibleAssetListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        sectionHorizontalInsets.leading -
        sectionHorizontalInsets.trailing
    }
}
