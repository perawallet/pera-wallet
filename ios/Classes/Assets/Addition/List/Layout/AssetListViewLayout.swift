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

    private lazy var theme = AssetListViewController.Theme()
    lazy var handlers = Handlers()

    private let listDataSource: AssetListViewDataSource

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
        case .asset:
            return CGSize(theme.cellSize)
        case .noContent:
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height - collectionView.adjustedContentInset.bottom
            return CGSize((width, height))
            
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
        if let loadingCell = cell as? AssetPreviewLoadingCell {
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
        if let loadingCell = cell as? AssetPreviewLoadingCell {
            loadingCell.stopAnimating()
        }
    }
}

extension AssetListViewLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width - listView.contentInset.horizontal
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: AssetListViewItem
    ) -> CGSize {
        let width = listView.bounds.width
        let height = listView.bounds.height - listView.adjustedContentInset.bottom
        return CGSize((width, height))
    }
}

extension AssetListViewLayout {
    struct Handlers {
        var didSelectAssetAt: ((IndexPath) -> Void)?
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    }
}
