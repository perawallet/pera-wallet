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

//   SelectAssetViewControllerListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SelectAssetViewControllerListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: SelectAssetViewControllerDataSource

    init(listDataSource: SelectAssetViewControllerDataSource) {
        self.listDataSource = listDataSource
    }
}

extension SelectAssetViewControllerListLayout {
    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension SelectAssetViewControllerListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        var inset = UIEdgeInsets()
        inset.top = 28
        inset.bottom = 16

        if listDataSource.isEmpty {
            inset.left = 24
            inset.right = 24
        }

        return inset
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemIdentifier = listDataSource.itemIdentifier(for: indexPath)

        switch itemIdentifier {
        case .asset(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetListItem: item,
                atSection: indexPath.section
            )
        case .collectibleAsset(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForCollectibleAssetListItem: item,
                atSection: indexPath.section
            )
        default:
            break
        }
        
        return listView(
            collectionView,
            layout: collectionViewLayout,
            sizeForLoadingItemAtSection: indexPath.section
        )
    }
}

extension SelectAssetViewControllerListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForLoadingItemAtSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        return CGSize(width: width, height: 72)
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetListItem item: SelectAssetListItem,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = AssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = AssetListItemCell.calculatePreferredSize(
            item.viewModel,
            for: AssetListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleAssetListItem item: SelectCollectibleAssetListItem,
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
            item.viewModel,
            for: CollectibleListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension SelectAssetViewControllerListLayout {
    private func calculateContentWidth(
        _ collectionView: UICollectionView,
        forSectionAt section: Int
    ) -> CGFloat {
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
