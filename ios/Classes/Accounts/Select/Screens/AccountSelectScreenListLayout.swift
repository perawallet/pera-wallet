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

//   AccountSelectScreenListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountSelectScreenListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: AccountSelectScreenDataSource
    private let theme: AccountSelectScreen.Theme

    init(
        listDataSource: AccountSelectScreenDataSource,
        theme: AccountSelectScreen.Theme
    ) {
        self.listDataSource = listDataSource
        self.theme = theme
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension AccountSelectScreenListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        return listView(collectionView, layout: collectionViewLayout, sizeForAccountItem: itemIdentifier)
    }
}

extension AccountSelectScreenListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: AccountSelectItem
    ) -> CGSize {
        switch item {
        case .empty(let emptyItem):
            switch emptyItem {
            case .loading:
                return CGSize(
                    width: calculateContentWidth(listView),
                    height: theme.cellHeight
                )
            case .noContent(let noContentItem):
                return NoContentCell.calculatePreferredSize(
                    noContentItem,
                    for: NoContentCell.theme,
                    fittingIn: CGSize((calculateContentWidth(listView), .greatestFiniteMagnitude))
                )
            }

        case .account(let cellItem):
            switch cellItem {
            case .header:
                return CGSize(
                    width: calculateContentWidth(listView),
                    height: theme.headerHeight
                )
            case .accountCell, .contactCell, .searchAccountCell, .matchedAccountCell:
                return CGSize(
                    width: calculateContentWidth(listView),
                    height: theme.cellHeight
                )
            }

        }
    }
}

extension AccountSelectScreenListLayout {
    private func calculateContentWidth(
        _ collectionView: UICollectionView
    ) -> LayoutMetric {
        return
            collectionView.bounds.width -
            collectionView.contentInset.horizontal
    }
}
