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

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

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
        
        var insets =
            UIEdgeInsets(
                (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
            )
        
        switch listSection {
        case .empty:
            return insets
        case .loading:
            insets.top = 72
            return insets
        case .portfolio:
            insets.top = 72
            return insets
        case .announcement:
            insets.top = 36
            return insets
        case .accounts:
            insets.top = 36
            insets.bottom = 8
            return insets
        case .watchAccounts:
            insets.top = 24
            insets.bottom = 8
            return insets
        case .buyAlgo:
            insets.top = sectionIdentifiers.contains(.announcement) ? 24 : 44
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
                sizeForPortfolioItem: item
            )
        case .account(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountItem: item
            )
        case .announcement(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAnnouncementCellItem: item
            )
        case .buyAlgo:
            return listViewBuyAlgo(
                collectionView,
                layout: collectionViewLayout
            )
        }
    }
}

extension HomeListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: HomeEmptyItem,
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
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPortfolioItem item: HomePortfolioViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = HomePortfolioCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(for: listView)
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
        sizeForAccountItem item: HomeAccountItem
    ) -> CGSize {
        switch item {
        case .header(let headerItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForAccountHeaderItem: headerItem
            )
        case .cell(let cellItem):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForAccountCellItem: cellItem
            )
        }
    }
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountHeaderItem item: HomeAccountSectionHeaderViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = TitleWithAccessorySupplementaryCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(for: listView)
        let newSize = TitleWithAccessorySupplementaryCell.calculatePreferredSize(
            item,
            for: TitleWithAccessorySupplementaryCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItem item: AccountPreviewViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = AccountPreviewCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(for: listView)
        let sampleAccountPreview = CustomAccountPreview(
            icon: "standard-orange".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountPreviewViewModel(sampleAccountPreview)
        let newSize = AccountPreviewCell.calculatePreferredSize(
            sampleAccountItem,
            for: AccountPreviewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAnnouncementCellItem item: AnnouncementViewModel
    ) -> CGSize {
        let width = calculateContentWidth(for: listView)

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

    private func listViewBuyAlgo(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let width = calculateContentWidth(for: listView)

        return BuyAlgoCell.calculatePreferredSize(
            for: BuyAlgoViewTheme(),
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
    }
}

extension HomeListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return
            listView.bounds.width -
            listView.contentInset.horizontal -
            sectionHorizontalInsets.leading -
            sectionHorizontalInsets.trailing
    }
}
