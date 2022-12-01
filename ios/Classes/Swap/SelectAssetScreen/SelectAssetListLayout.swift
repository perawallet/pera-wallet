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

//   SelectAssetListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SelectAssetListLayout: NSObject {
    private lazy var theme = SelectAssetScreenTheme()

    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: SelectAssetDataSource

    init(
        listDataSource: SelectAssetDataSource
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

extension SelectAssetListLayout {
    func collectionView(
        _ view: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .empty,
            .error:
            return theme.emptySectionInsets
        case .assets:
            return theme.assetSectionInsets
        }
    }

    func collectionView(
        _ view: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((view.bounds.width, 0))
        }

        switch itemIdentifier {
        case .empty(let item):
            return collectionView(
                view,
                layout: collectionViewLayout,
                sizeForEmptyItem: item,
                atSection: indexPath.section
            )
        case .asset(let item):
            return collectionView(
                view,
                layout: collectionViewLayout,
                sizeForAssetItem: item,
                atSection: indexPath.section
            )
        case .error(let item):
            return collectionView(
                view,
                layout: collectionViewLayout,
                sizeForNoContent: item,
                atSection: indexPath.section
            )
        }
    }
}

extension SelectAssetListLayout {
    private func collectionView(
        _ view: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: SelectAssetEmptyItem,
        atSection section: Int
    ) -> CGSize {
        switch item {
        case .loading:
            return collectionView(
                view,
                layout: collectionViewLayout,
                sizeForLoadingItem: item,
                atSection: section
            )
        case .noContent(let viewModel):
            return collectionView(
                view,
                layout: collectionViewLayout,
                sizeForNoContent: viewModel,
                atSection: section
            )
        }
    }

    private func collectionView(
        _ view: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForLoadingItem item: SelectAssetEmptyItem,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            view,
            forSectionAt: section
        )

        /// <todo> Update loading asset item calculation when the account selection PR is merged.
        let size = PreviewLoadingView.calculatePreferredSize(
            for: PreviewLoadingViewCommonTheme(),
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        return CGSize(width: width, height: size.height)
    }

    private func collectionView(
        _ view: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForNoContent item: NoContentViewModel,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            view,
            forSectionAt: section
        )
        let sectionInset = collectionView(
            view,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
        let height =
            view.bounds.height -
            sectionInset.vertical -
            view.adjustedContentInset.bottom
        return CGSize((width, height))
    }
}

extension SelectAssetListLayout {
    private func collectionView(
        _ view: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForAssetItem item: SelectAssetListItem,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = SelectAssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            view,
            forSectionAt: section
        )
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let newSize = SelectAssetListItemCell.calculatePreferredSize(
            item.viewModel,
            for: SelectAssetListItemCell.theme,
            fittingIn: maxSize
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension SelectAssetListLayout {
    private func calculateContentWidth(
        _ view: UICollectionView,
        forSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = collectionView(
            view,
            layout: view.collectionViewLayout,
            insetForSectionAt: section
        )
        return
            view.bounds.width -
            view.contentInset.horizontal -
            sectionInset.left -
            sectionInset.right
    }
}
