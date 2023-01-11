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
//   AccountAssetListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

/// <todo>
/// Refactor. See `HomeListLayout`
final class AccountAssetListLayout: NSObject {
    lazy var handlers = Handlers()
    
    private var sizeCache: [String: CGSize] = [:]

    private lazy var theme = Theme()

    private let isWatchAccount: Bool
    private let listDataSource: AccountAssetListDataSource

    init(
        isWatchAccount: Bool,
        listDataSource: AccountAssetListDataSource
    ) {
        self.isWatchAccount = isWatchAccount
        self.listDataSource = listDataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension AccountAssetListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        handlers.willDisplay?(cell, indexPath)
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
        case .portfolio(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForPortfolioItem: item,
                atSection: indexPath.section
            )
        case .watchPortfolio(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForWatchPortfolioItem: item,
                section: indexPath.section
            )
        case .assetManagement,
             .watchAccountAssetManagement:
            return CGSize(theme.assetManagementItemSize)
        case .search:
            return CGSize(theme.searchItemSize)
        case let .asset(item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetCellItem: item,
                atSection: indexPath.section
            )
        case .pendingAsset:
            return CGSize(theme.assetItemSize)
        case .quickActions:
            let width = calculateContentWidth(
                collectionView,
                forSectionAt: indexPath.section
            )

            return AccountQuickActionsCell.calculatePreferredSize(
                for: AccountQuickActionsViewTheme(),
                fittingIn: CGSize((width, .greatestFiniteMagnitude))
            )
        case .empty(let item):
            return sizeForNoContent(
                collectionView,
                item: item,
                atSection: indexPath.section
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        let insets: UIEdgeInsets = .zero

        switch listSection {
        case .quickActions:
            return UIEdgeInsets(top: 0, left: 0, bottom: 36, right: 0)
        case .assets:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .portfolio:
            return UIEdgeInsets(top: 0, left: 0, bottom: isWatchAccount ? 36 : 0, right: 0)
        default:
            return insets
        }
    }
}

extension AccountAssetListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPortfolioItem item: AccountPortfolioViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = AccountPortfolioCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = AccountPortfolioCell.calculatePreferredSize(
            item,
            for: AccountPortfolioCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude)))
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForWatchPortfolioItem item: WatchAccountPortfolioViewModel,
        section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = WatchAccountPortfolioCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(listView, forSectionAt: section)
        let newSize = WatchAccountPortfolioCell.calculatePreferredSize(
            item,
            for: WatchAccountPortfolioCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude)))

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetCellItem item: AssetListItemViewModel,
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
            item,
            for: AssetListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForNoContent(
        _ listView: UICollectionView,
        item: AssetListSearchNoContentViewModel,
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
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension AccountAssetListLayout {
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

extension AccountAssetListLayout {
    struct Handlers {
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    }
}
