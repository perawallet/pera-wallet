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

//   DiscoverSearchScreenLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class DiscoverSearchScreenLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: DiscoverSearchDataSource
    private let dataController: DiscoverSearchDataController?

    init(
        listDataSource: DiscoverSearchDataSource,
        dataController: DiscoverSearchDataController?
    ) {
        self.listDataSource = listDataSource
        self.dataController = dataController
        super.init()
    }

    static func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension DiscoverSearchScreenLayout {
    func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let sectionIdentifier = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch sectionIdentifier {
        case .noContent: return .init(top: 20, left: 24, bottom: 0, right: 24)
        case .list: return .init(top: 20, left: 0, bottom: 0, right: 0)
        case .nextList: return .init(top: 0, left: 24, bottom: 0, right: 24)
        }
    }

    func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((listView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .loading:
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForLoadingItemAt: indexPath
            )
        case .notFound:
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForNotFoundItemAt: indexPath
            )
        case .error(let errorItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForErrorItem: errorItem,
                at: indexPath
            )
        case .asset(let assetItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForAssetItem: assetItem,
                at: indexPath
            )
        case .nextLoading:
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForNextLoadingItemAt: indexPath
            )
        case .nextError(let errorItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForNextErrorItem: errorItem,
                at: indexPath
            )
        }
    }
}

extension DiscoverSearchScreenLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForLoadingItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return DiscoverSearchListLoadingCell.calculatePreferredSize(
            for: DiscoverSearchListLoadingCell.theme,
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
        let minSize = self.listView(
            listView,
            layout: listViewLayout,
            minSizeForNoContentItemAt: indexPath
        )
        let preferredSize = DiscoverSearchListNotFoundCell.calculatePreferredSize(
            DiscoverSearchListNotFoundViewModel(),
            for: DiscoverSearchListNotFoundCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
        return .init(width: width, height: max(minSize.height, preferredSize.height))
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForErrorItem item: DiscoverSearchErrorItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let minSize = self.listView(
            listView,
            layout: listViewLayout,
            minSizeForNoContentItemAt: indexPath
        )
        let preferredSize = DiscoverErrorCell.calculatePreferredSize(
            DiscoverSearchListErrorViewModel(error: item),
            for: DiscoverErrorCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
        return .init(width: width, height: max(minSize.height, preferredSize.height))
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        minSizeForNoContentItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let sectionInset = self.listView(
            listView,
            layout: listViewLayout,
            insetForSectionAt: indexPath.section
        )
        let height =
            listView.bounds.height -
            sectionInset.vertical -
            listView.adjustedContentInset.vertical
        return .init(width: width, height: height)
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetItem item: DiscoverSearchAssetListItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let cacheIdentifier = HomeQuickActionsCell.reuseIdentifier

        if let cachedSize = sizeCache[cacheIdentifier] {
            return cachedSize
        }

        let viewModel = dataController?.searchAssetListItemViewModel(for: item.assetID)
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = DiscoverSearchAssetCell.calculatePreferredSize(
            viewModel,
            for: DiscoverSearchAssetCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[cacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForNextLoadingItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return .init(width: width, height: 120)
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForNextErrorItem item: DiscoverSearchErrorItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return DiscoverSearchNextListErrorCell.calculatePreferredSize(
            DiscoverSearchNextListErrorViewModel(error: item),
            for: DiscoverSearchNextListErrorCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
    }
}

extension DiscoverSearchScreenLayout {
    private func calculateContentWidth(
        _ listView: UICollectionView,
        forSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = self.listView(
            listView,
            layout: listView.collectionViewLayout,
            insetForSectionAt: section
        )
        return
            listView.bounds.width -
            listView.adjustedContentInset.horizontal -
            sectionInset.horizontal
    }
}
