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

//   WebImportSuccessScreenListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WebImportSuccessScreenListLayout: NSObject {
    private let listDataSource: WebImportSuccessScreenDataSource
    private let theme = WebImportSuccessScreenTheme()

    init(
        listDataSource: WebImportSuccessScreenDataSource
    ) {
        self.listDataSource = listDataSource
        super.init()
    }
}

extension WebImportSuccessScreenListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets((0, 24, 0, 24))
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
                at: indexPath
            )
        case .header(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item,
                at: indexPath
            )
        case .asbHeader(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAsbHeaderItem: item,
                at: indexPath
            )
        case .missingAccounts(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForMissingAccountItem: item,
                at: indexPath
            )
        case .asbMissingAccounts(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAsbMissingAccountItem: item,
                at: indexPath
            )
        }
    }
}

extension WebImportSuccessScreenListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = collectionView(
            listView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
        return listView.bounds.width - sectionInset.horizontal
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: WebImportSuccessListViewAccountItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            for: listView,
            layout: listViewLayout,
            insetForSectionAt: indexPath.section
        )
        let height = theme.listItemHeight
        return CGSize((width, height))
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: WebImportSuccessListHeaderItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            for: listView,
            layout: listViewLayout,
            insetForSectionAt: indexPath.section
        )

        let viewModel = WebImportSuccessHeaderViewModel(
            importedAccountCount: item.importedAccountCount
        )

        return WebImportSuccessHeaderView.calculatePreferredSize(
            viewModel,
            for: WebImportSuccessHeaderViewTheme(),
            fittingIn: CGSize(width: width, height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAsbHeaderItem item: WebImportSuccessListHeaderItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            for: listView,
            layout: listViewLayout,
            insetForSectionAt: indexPath.section
        )

        let viewModel = AlgorandSecureBackupImportSuccessHeaderViewModel(
            importedAccountCount: item.importedAccountCount
        )

        return WebImportSuccessHeaderView.calculatePreferredSize(
            viewModel,
            for: WebImportSuccessHeaderViewTheme(),
            fittingIn: CGSize(width: width, height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForMissingAccountItem item: WebImportSuccessListMissingAccountItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            for: listView,
            layout: listViewLayout,
            insetForSectionAt: indexPath.section
        )

        let viewModel = WebImportSuccessInfoBoxViewModel(
            unimportedAccountCount: item.unimportedAccountCount
        )

        return WebImportSuccessInfoBoxCell.calculatePreferredSize(
            viewModel,
            for: WebImportSuccessInfoBoxTheme(),
            fittingIn: CGSize(width: width, height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAsbMissingAccountItem item: WebImportSuccessListMissingAccountItem,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            for: listView,
            layout: listViewLayout,
            insetForSectionAt: indexPath.section
        )

        let viewModel = AlgorandSecureBackupImportSuccessInfoBoxViewModel(
            unimportedAccountCount: item.unimportedAccountCount,
            unsupportedAccountCount: item.unsupportedAccountCount
        )

        return WebImportSuccessInfoBoxCell.calculatePreferredSize(
            viewModel,
            for: WebImportSuccessInfoBoxTheme(),
            fittingIn: CGSize(width: width, height: .greatestFiniteMagnitude)
        )
    }
}
