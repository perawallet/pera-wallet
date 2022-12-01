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

        switch itemIdentifier {
        case .empty(let emptyItem):
            switch emptyItem {
            case .loading:
                let width = calculateContentWidth(
                    for: collectionView,
                    forSectionAt: indexPath.section
                )
                return CGSize(
                    width: width,
                    height: theme.cellHeight
                )
            case .noContent(let noContentItem):
                let width = calculateContentWidth(
                    for: collectionView,
                    forSectionAt: indexPath.section
                )
                return NoContentCell.calculatePreferredSize(
                    noContentItem,
                    for: NoContentCell.theme,
                    fittingIn: CGSize((width, .greatestFiniteMagnitude))
                )
            }

        case .account(let cellItem):
            switch cellItem {
            case .header:
                let width = calculateContentWidth(
                    for: collectionView,
                    forSectionAt: indexPath.section
                )
                return CGSize(
                    width: width,
                    height: theme.headerHeight
                )
            case .accountCell,
                 .contactCell,
                 .searchAccountCell,
                 .matchedAccountCell:
                let width = calculateContentWidth(
                    for: collectionView,
                    forSectionAt: indexPath.section
                )
                return CGSize(
                    width: width,
                    height: theme.cellHeight
                )
            }
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

        switch listSection {
        case .empty:
            return .zero
        case .matched,
             .accounts,
             .contacts,
             .searchResult:
            return UIEdgeInsets(
                top: 36,
                left: 24,
                bottom: 0,
                right: 24
            )
        }
    }
}

extension AccountSelectScreenListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView,
        forSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = self.collectionView(
            listView,
            layout: listView.collectionViewLayout,
            insetForSectionAt: section
        )
        return
            listView.bounds.width -
            listView.contentInset.horizontal -
            sectionInset.left -
            sectionInset.right
    }
}
