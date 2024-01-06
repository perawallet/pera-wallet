// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupAccountListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupAccountListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: AlgorandSecureBackupAccountListDataSource

    init(
        listDataSource: AlgorandSecureBackupAccountListDataSource
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

extension AlgorandSecureBackupAccountListLayout {
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
        case .accounts:
            return UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 8,
                right: 0
            )
        case .empty:
            return .zero
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
        case .account(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountItem: item,
                atSection: indexPath.section
            )
        case .noContent:
            return sizeForNoContent(
                collectionView,
                layout: collectionViewLayout
            )
        }
    }
}

extension AlgorandSecureBackupAccountListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: AlgorandSecureBackupAccountListAccountItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        switch item {
        case .header(let item):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForAccountHeaderItem: item,
                atSection: section
            )
        case .cell(let item):
            return self.listView(
                listView,
                layout: listViewLayout,
                sizeForAccountCellItem: item.viewModel,
                atSection: section
            )
        }
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountHeaderItem item: AlgorandSecureBackupAccountListAccountsHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = AlgorandSecureBackupAccountListAccountsHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let newSize = AlgorandSecureBackupAccountListAccountsHeader.calculatePreferredSize(
            item,
            for: AlgorandSecureBackupAccountListAccountsHeader.theme,
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
        let sizeCacheIdentifier = AlgorandSecureBackupAccountListAccountCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = AlgorandSecureBackupAccountListAccountCell.calculatePreferredSize(
            sampleAccountItem,
            for: AlgorandSecureBackupAccountListAccountCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForNoContent(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let theme = AlgorandSecureBackupAccountListScreenTheme()
        let verticalInsets = theme.listContentTopInset +
            theme.spacingBetweenListAndContinueAction +
            theme.continueActionContentEdgeInsets.bottom +
            theme.continueActionEdgeInsets.top +
            theme.continueActionEdgeInsets.bottom
        
        let width = listView.bounds.width
        let height = listView.bounds.height - listView.contentInset.vertical - verticalInsets

        let size = CGSize(width: width, height: height)

        sizeCache[sizeCacheIdentifier] = size

        return size
    }
}

extension AlgorandSecureBackupAccountListLayout {
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
