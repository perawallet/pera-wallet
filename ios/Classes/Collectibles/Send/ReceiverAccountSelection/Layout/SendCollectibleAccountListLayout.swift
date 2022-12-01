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

//   SendCollectibleAccountListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SendCollectibleAccountListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: SendCollectibleAccountListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    init(
        listDataSource: SendCollectibleAccountListDataSource
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

extension SendCollectibleAccountListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        var insets = UIEdgeInsets(
            (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
        )

        switch listSection {
        case .empty:
            return insets
        case .loading:
            insets.top = 36
            insets.bottom = 8
            return insets
        case .accounts:
            insets.top = 36
            insets.bottom = 8
            insets.left = 0
            insets.right = 0
            return insets
        case .contacts:
            insets.top = 36
            insets.bottom = 8
            insets.left = 0
            insets.right = 0
            return insets
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
        case .empty(let item):
            switch item {
            case .loading:
                return sizeForLoadingItem(
                    collectionView,
                    layout: collectionViewLayout
                )
            case .noContent:
                return sizeForSearchNoContent(
                    collectionView
                )
            }
        case .header(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForHeaderItem: item
            )
        case .account(let item, _):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountItem: item
            )
        case .contact(let item, _):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForContactItem: item
            )
        }
    }
}

extension SendCollectibleAccountListLayout {
    private func sizeForSearchNoContent(
        _ listView: UICollectionView
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let item = AccountSelectSearchNoContentViewModel()
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn:  CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func sizeForLoadingItem(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout
    ) -> CGSize {
        let sizeCacheIdentifier = PreviewLoadingCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: nil
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = SendCollectibleAccountListItemCell.calculatePreferredSize(
            sampleAccountItem,
            for: SendCollectibleAccountListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: SendCollectibleAccountListHeaderViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = SendCollectibleAccountListTitleSupplementaryCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = SendCollectibleAccountListTitleSupplementaryCell.calculatePreferredSize(
            item,
            for: SendCollectibleAccountListTitleSupplementaryCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: AccountListItemViewModel?
    ) -> CGSize {
        let sizeCacheIdentifier = SendCollectibleAccountListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: nil
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = SendCollectibleAccountListItemCell.calculatePreferredSize(
            sampleAccountItem,
            for: SendCollectibleAccountListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForContactItem item: ContactsViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = SendCollectibleContactCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width

        let newSize = SendCollectibleContactCell.calculatePreferredSize(
            item,
            for: SendCollectibleContactCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension SendCollectibleAccountListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        sectionHorizontalInsets.leading -
        sectionHorizontalInsets.trailing
    }
}
