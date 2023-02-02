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

//   ManageAssetsListLayout.swift

import Foundation
import UIKit
import MacaroonUIKit

final class ManageAssetsListLayout: NSObject {
    private let dataSource: ManageAssetsListDataSource
    
    private var sizeCache: [String: CGSize] = [:]
    
    init(
        _ dataSource: ManageAssetsListDataSource
    ) {
        self.dataSource = dataSource
    }
}

extension ManageAssetsListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .empty:
            return UIEdgeInsets(
                top: 0,
                left: 24,
                bottom: 0,
                right: 24
            )
        case .assets:
            return UIEdgeInsets(
                top: 20,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }
        
        switch itemIdentifier {
        case .asset(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetCellItem: item,
                forSectionAt: indexPath.section
            )
        case .collectibleAsset(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForCollectibleAssetCellItem: item,
                forSectionAt: indexPath.section
            )
        case .empty(let item):
            return sizeForNoContent(
                collectionView,
                item: item,
                forSectionAt: indexPath.section
            )
        }
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetCellItem item: OptOutAssetListItem,
        forSectionAt section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = OptOutAssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let newSize = OptOutAssetListItemCell.calculatePreferredSize(
            item.viewModel,
            for: OptOutAssetListItemCell.theme,
            fittingIn: maxSize
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleAssetCellItem item: OptOutCollectibleAssetListItem,
        forSectionAt section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = OptOutCollectibleAssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let newSize = OptOutCollectibleAssetListItemCell.calculatePreferredSize(
            item.viewModel,
            for: OptOutCollectibleAssetListItemCell.theme.context,
            fittingIn: maxSize
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
    
    private func sizeForNoContent(
        _ listView: UICollectionView,
        item: AssetListSearchNoContentViewModel,
        forSectionAt section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        return newSize
    }
}

extension ManageAssetsListLayout {
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
