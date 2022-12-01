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
//   HomeListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]
    
    private let listDataSource: HomeListDataSource

    init(
        listDataSource: HomeListDataSource
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

extension HomeListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers
        
        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }
        
        switch listSection {
        case .accounts: return UIEdgeInsets(top: 36, left: 0, bottom: 24, right: 0)
        default: return .zero
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
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForEmptyItem: item,
                atSection: indexPath.section
            )
        case .portfolio(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForPortfolioItem: item,
                atSection: indexPath.section
            )
        case .account(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountItem: item,
                atSection: indexPath.section
            )
        case .announcement(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAnnouncementCellItem: item,
                atSection: indexPath.section
            )
        }
    }
}

extension HomeListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: HomeEmptyItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
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
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPortfolioItem item: HomePortfolioItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        switch item {
        case .portfolio(let portfolioItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForPortfolioValueItem: portfolioItem,
                atSection: section
            )
        case .quickActions:
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForQuickActions: item,
                atSection: section
            )
        }

    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPortfolioValueItem item: HomePortfolioViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = HomePortfolioCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = HomePortfolioCell.calculatePreferredSize(
            item,
            for: HomePortfolioCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude)))

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForQuickActions item: HomePortfolioItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = HomeQuickActionsCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = HomeQuickActionsCell.calculatePreferredSize(
            for: HomeQuickActionsViewTheme(),
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: HomeAccountItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        switch item {
        case .header(let headerItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForAccountHeaderItem: headerItem,
                atSection: section
            )
        case .cell(let cellItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForAccountCellItem: cellItem,
                atSection: section
            )
        }
    }
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountHeaderItem item: ManagementItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = HomeAccountsHeader.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = HomeAccountsHeader.calculatePreferredSize(
            item,
            for: HomeAccountsHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItem item: AccountListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = HomeAccountCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = HomeAccountCell.calculatePreferredSize(
            sampleAccountItem,
            for: HomeAccountCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAnnouncementCellItem item: AnnouncementViewModel,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )

        if item.isGeneric {
            return GenericAnnouncementCell.calculatePreferredSize(
                item,
                for: GenericAnnouncementViewTheme(),
                fittingIn: CGSize((width, .greatestFiniteMagnitude))
            )
        } else {
            return GovernanceAnnouncementCell.calculatePreferredSize(
                item,
                for: GovernanceAnnouncementViewTheme(),
                fittingIn: CGSize((width, .greatestFiniteMagnitude))
            )
        }
    }
}

extension HomeListLayout {
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
