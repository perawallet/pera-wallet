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

//   ExportAccountListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ExportAccountListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: ExportAccountListDataSource

    init(
        listDataSource: ExportAccountListDataSource
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

extension ExportAccountListLayout {
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
        case .empty:
            return .zero
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
            sizeForHeaderItem: listDataSource.listHeader,
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
        case .noContent:
            return sizeForNoContent(
                collectionView,
                item: ExportAccountListItemNoContentViewModel(),
                atSection: indexPath.section
            )
        }
    }
}

extension ExportAccountListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: ExportAccountListAccountItemIdentifier,
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
        sizeForAccountHeaderItem item: ExportAccountListAccountsHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = ExportAccountListAccountsHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let newSize = ExportAccountListAccountsHeader.calculatePreferredSize(
            item,
            for: ExportAccountListAccountsHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItem item: AccountPreviewViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = ExportAccountListAccountCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let sampleAccountListItem = CustomAccountPreview(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountPreviewViewModel(sampleAccountListItem)
        let newSize = ExportAccountListAccountCell.calculatePreferredSize(
            sampleAccountItem,
            for: ExportAccountListAccountCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        sizeForHeaderItem item: ExportAccountListItemHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = ExportAccountListItemHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        )
        let newSize = ExportAccountListItemHeader.calculatePreferredSize(
            item,
            for: ExportAccountListItemHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForNoContent(
        _ listView: UICollectionView,
        item: ExportAccountListItemNoContentViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let theme = ExportAccountListScreenTheme()
        let noContentAdditionalHorizontalInset = theme.noContentAdditionalHorizontalInset.leading +
            theme.noContentAdditionalHorizontalInset.trailing

        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        ) - noContentAdditionalHorizontalInset

        let safeAreaBottom = listView.compactSafeAreaInsets.bottom
        let bottom = safeAreaBottom + theme.continueActionContentEdgeInsets.bottom

        let height = listView.bounds.height -
            listView.adjustedContentInset.bottom -
            listView.contentInset.top -
            bottom -
            theme.continueActionEdgeInsets.top -
            theme.continueActionEdgeInsets.bottom -
            theme.spacingBetweenListAndContinueAction

        let size = CGSize(
            width: width,
            height: height
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }
}

extension ExportAccountListLayout {
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
