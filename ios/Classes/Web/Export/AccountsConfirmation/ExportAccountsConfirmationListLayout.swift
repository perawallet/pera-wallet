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

//   ExportAccountsConfirmationListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ExportAccountsConfirmationListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: ExportAccountsConfirmationListDataSource
    private let hasSingularAccount: Bool

    init(
        listDataSource: ExportAccountsConfirmationListDataSource,
        hasSingularAccount: Bool
    ) {
        self.listDataSource = listDataSource
        self.hasSingularAccount = hasSingularAccount
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension ExportAccountsConfirmationListLayout {
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
                top: 40,
                left: 0,
                bottom: 8,
                right: 0
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section],
              listSection == .accounts else {
            return CGSize((collectionView.bounds.width, 0))
        }

        let size = listView(
            collectionView,
            sizeForHeaderItem: ExportAccountsConfirmationListItemHeaderViewModel(hasSingularAccount: hasSingularAccount),
            atSection: section
        )
        return size
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
        }
    }
}

extension ExportAccountsConfirmationListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: ExportAccountsConfirmationListAccountItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        switch item {
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
        sizeForAccountCellItem item: AccountListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = ExportAccountsConfirmationListAccountCell.reuseIdentifier

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
        let newSize = ExportAccountsConfirmationListAccountCell.calculatePreferredSize(
            sampleAccountItem,
            for: ExportAccountsConfirmationListAccountCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        sizeForHeaderItem item: ExportAccountsConfirmationListItemHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = ExportAccountsConfirmationListItemHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        )
        let newSize = ExportAccountsConfirmationListItemHeader.calculatePreferredSize(
            item,
            for: ExportAccountsConfirmationListItemHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension ExportAccountsConfirmationListLayout {
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
