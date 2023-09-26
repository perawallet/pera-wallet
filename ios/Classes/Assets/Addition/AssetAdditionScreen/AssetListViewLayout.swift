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

//
//   AssetListViewLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetListViewLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let dataSource: AssetListViewDataSource
    private let dataController: AssetListViewDataController

    init(
        dataSource: AssetListViewDataSource,
        dataController: AssetListViewDataController
    ) {
        self.dataSource = dataSource
        self.dataController = dataController
        super.init()
    }
    
    static func build() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        return flowLayout
    }
}

extension AssetListViewLayout {
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
        case .noContent: return .init(top: 16, left: 24, bottom: 0, right: 24)
        case .content: return .init(top: 16, left: 0, bottom: 0, right: 0)
        case .waitingForMore: return .init(top: 0, left: 24, bottom: 0, right: 24)
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
        case .loading:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForLoadingItemAt: indexPath
            )
        case .loadingFailed(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForLoadingFailedItem: item,
                at: indexPath
            )
        case .notFound:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForNotFoundItemAt: indexPath
            )
        case .asset(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetItem: item,
                at: indexPath
            )
        case .loadingMore:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForLoadingMoreItemAt: indexPath
            )
        case .loadingMoreFailed(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForLoadingMoreFailedItem: item,
                at: indexPath
            )
        }
    }
}

extension AssetListViewLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForLoadingItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return OptInAssetListLoadingCell.calculatePreferredSize(
            for: OptInAssetListLoadingCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForLoadingFailedItem item: OptInAssetList.ErrorItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return NoContentWithActionCell.calculatePreferredSize(
            OptInAssetListErrorViewModel(error: item),
            for: NoContentWithActionCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForNotFoundItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return NoContentCell.calculatePreferredSize(
            OptInAssetListNotFoundViewModel(),
            for: NoContentCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetItem item: OptInAssetList.AssetItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let cacheIdentifier = OptInAssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[cacheIdentifier] {
            return cachedSize
        }

        let viewModel: OptInAssetListItemViewModel? = dataController[item.assetID]
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = OptInAssetListItemCell.calculatePreferredSize(
            viewModel,
            for: OptInAssetListItemCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[cacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForLoadingMoreItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return .init(width: width, height: 174)
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForLoadingMoreFailedItem item: OptInAssetList.ErrorItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return NoContentWithActionCell.calculatePreferredSize(
            OptInAssetNextListErrorViewModel(error: item),
            for: NoContentWithActionCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
    }
}

extension AssetListViewLayout {
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
