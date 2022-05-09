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

/// <todo>
/// Refactor, move `UICollectionViewDelegateFlowLayout` to the screen.
final class AssetListViewLayout: NSObject {
    private lazy var theme = AssetListViewController.Theme()
    lazy var handlers = Handlers()

    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: AssetListViewDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    init(
        listDataSource: AssetListViewDataSource
    ) {
        self.listDataSource = listDataSource

        super.init()
    }
}

extension AssetListViewLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .loading:
            return CGSize(theme.cellSize)
        case .asset(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetCellItem: item
            )
        case .noContent:
            return sizeForSearchNoContent(
                collectionView
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
        
        var insets =
        UIEdgeInsets(
            (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
        )

        switch listSection {
        case .empty:
            return insets
        case .assets:
            insets.top = 24
            return insets
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handlers.didSelectAssetAt?(indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let loadingCell = cell as? PreviewLoadingCell {
            loadingCell.startAnimating()
            return
        }

        handlers.willDisplay?(cell, indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let loadingCell = cell as? PreviewLoadingCell {
            loadingCell.stopAnimating()
        }
    }
}

extension AssetListViewLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        sectionHorizontalInsets.leading -
        sectionHorizontalInsets.trailing
    }

    private func sizeForSearchNoContent(
        _ listView: UICollectionView
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let item = AssetAdditionNoContentViewModel()
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn:  CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetCellItem item: AssetPreviewViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = AssetPreviewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)

        let newSize = AssetPreviewCell.calculatePreferredSize(
            item,
            for: AssetPreviewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleAssetCellItem item: AssetPreviewViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = AssetPreviewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)

        let newSize = AssetPreviewCell.calculatePreferredSize(
            item,
            for: AssetPreviewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension AssetListViewLayout {
    struct Handlers {
        var didSelectAssetAt: ((IndexPath) -> Void)?
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    }
}
