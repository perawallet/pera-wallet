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
    private lazy var theme = Theme()
    lazy var handlers = Handlers()
    
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: AccountAssetListDataSource
    private let accountHandle: AccountHandle

    init(
        accountHandle: AccountHandle,
        listDataSource: AccountAssetListDataSource
    ) {
        self.accountHandle = accountHandle
        self.listDataSource = listDataSource

        super.init()
    }
}

extension AccountAssetListLayout: UICollectionViewDelegateFlowLayout {
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
        guard let section = AccountAssetsSection(rawValue: section) else {
            return .zero
        }

        switch section {
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
        guard let section = AccountAssetsSection(rawValue: section) else {
            return .zero
        }

        switch section {
        case .portfolio:
            return .zero
        case .assets:
            if accountHandle.value.isWatchAccount() {
                return .zero
            }

            return CGSize(theme.listFooterSize)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = AccountAssetsSection(rawValue: indexPath.section),
              section == .assets else {
            return
        }

        if indexPath.item == 0 {
            handlers.didSelectSearch?()
            return
        }

        if indexPath.item == 1 {
            handlers.didSelectAlgoDetail?()
            return
        }

        /// Reduce search and algos cells from index
        if let assetDetail = accountHandle.value.compoundAssets[safe: indexPath.item - 2] {
            handlers.didSelectAsset?(assetDetail)
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

extension AccountAssetListLayout {
    struct Handlers {
        var didSelectSearch: EmptyHandler?
        var didSelectAlgoDetail: EmptyHandler?
        var didSelectAsset: ((CompoundAsset) -> Void)?
    }
}
