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

//   ReceiveCollectibleAccountListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ReceiveCollectibleAccountListLayout: NSObject {
    private var insetCache: [ReceiveCollectibleAccountListSection: UIEdgeInsets] = [:]
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: ReceiveCollectibleAccountListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    init(
        listDataSource: ReceiveCollectibleAccountListDataSource
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

extension ReceiveCollectibleAccountListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        return listView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: listSection
        )
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
        case .empty(let item):
            switch item {
            case .loading:
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForAccountCellItem: nil
                )
            case .noContent:
                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForEmptyItem: item,
                    atSection: indexPath.section
                )
            }
        case .info:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForInfoItem: .init()
            )
        case .header(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item
            )
        case .account(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountCellItem: item
            )
        }
    }
}

extension ReceiveCollectibleAccountListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        insetForSectionAt section: ReceiveCollectibleAccountListSection
    ) -> UIEdgeInsets {
        if let insetCache = insetCache[section] {
            return insetCache
        }

        var insets = UIEdgeInsets(
            (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
        )

        switch section {
        case .empty:
            break
        case .loading:
            let infoHeight = self.listView(
                listView,
                layout: listViewLayout,
                sizeForInfoItem: .init()
            ).height
            let infoSectionVerticalInsets = self.listView(
                listView,
                layout: listViewLayout,
                insetForSectionAt: .info
            ).vertical
            let headerHeight = self.listView(
                listView,
                layout: listViewLayout,
                sizeForHeaderItem: ReceiveCollectibleAccountListHeaderViewModel()
            ).height
            let headerSectionVerticalInsets = self.listView(
                listView,
                layout: listViewLayout,
                insetForSectionAt: .header
            ).vertical
            let accountsSectionTopInset = self.listView(
                listView,
                layout: listViewLayout,
                insetForSectionAt: .accounts
            ).top
            let topInset =
            infoHeight +
            infoSectionVerticalInsets +
            headerHeight +
            headerSectionVerticalInsets +
            accountsSectionTopInset +
            AccountListItemCell.contextPaddings.top

            insets.top = topInset
            insets.bottom = 8
        case .info:
            insets.top = 20
        case .header:
            insets.top = 24
        case .accounts:
            insets.top = 24
            insets.bottom = 8
        }

        insetCache[section] = insets

        return insets
    }

    func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForInfoItem item: ReceiveCollectibleAccountListInfoViewModel
    )-> CGSize {
        let sizeCacheIdentifier = ReceiveCollectibleInfoBoxCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = ReceiveCollectibleInfoBoxCell.calculatePreferredSize(
            item,
            for: ReceiveCollectibleInfoBoxCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: ReceiveCollectibleAccountListHeaderViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = TitleSupplementaryCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = TitleSupplementaryCell.calculatePreferredSize(
            item,
            for: TitleSupplementaryCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension ReceiveCollectibleAccountListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: ReceiveCollectibleAccountListEmptyItem,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(for: listView)
        let sectionInset = collectionView(
            listView,
            layout: listViewLayout,
            insetForSectionAt: section
        )
        let height =
            listView.bounds.height -
            sectionInset.vertical -
            listView.safeAreaTop -
            listView.safeAreaBottom
        return CGSize((width, height))
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItem item: AccountListItemViewModel?
    ) -> CGSize {
        let sizeCacheIdentifier = AccountListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = AccountListItemCell.calculatePreferredSize(
            sampleAccountItem,
            for: AccountListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension ReceiveCollectibleAccountListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return
            listView.bounds.width -
            listView.contentInset.horizontal -
            sectionHorizontalInsets.leading -
            sectionHorizontalInsets.trailing
    }
}
