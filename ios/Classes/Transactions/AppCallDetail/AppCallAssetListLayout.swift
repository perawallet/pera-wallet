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

//   AppCallAssetListViewLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AppCallAssetListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: AppCallAssetListDataSource

    init(
        listDataSource: AppCallAssetListDataSource
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

extension AppCallAssetListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .cell(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForPreviewCellItem: item.viewModel
            )
        }
    }
}

extension AppCallAssetListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPreviewCellItem item: AppCallAssetPreviewWithImageViewModel?
    ) -> CGSize {
        let sizeCacheIdentifier = AppCallAssetPreviewWithImageCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let newSize = AppCallAssetPreviewWithImageCell.calculatePreferredSize(
            item,
            for: AppCallAssetPreviewWithImageCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}
