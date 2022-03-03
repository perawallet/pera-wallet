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
                sizeForPortfolioItem: item
            )
        case .search:
            return CGSize(theme.searchItemSize)
        case .asset,
             .pendingAsset:
            return CGSize(theme.assetItemSize)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .portfolio:
            return .zero
        case .assets:
            return CGSize(theme.listHeaderSize)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .portfolio:
            return .zero
        case .assets:
            if isWatchAccount {
                return .zero
            }

            return CGSize(theme.listFooterSize)
        }
    }
}

extension AccountAssetListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPortfolioItem item: AccountPortfolioViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = AccountPortfolioCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(for: listView)
        let newSize = AccountPortfolioCell.calculatePreferredSize(
            item,
            for: AccountPortfolioCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude)))
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }
}

extension AccountAssetListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width - listView.contentInset.horizontal
    }
}
