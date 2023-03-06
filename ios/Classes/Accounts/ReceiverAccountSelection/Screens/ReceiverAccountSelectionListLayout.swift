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

//   ReceiverAccountSelectionListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ReceiverAccountSelectionListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: ReceiverAccountSelectionListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    init(
        listDataSource: ReceiverAccountSelectionListDataSource
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

extension ReceiverAccountSelectionListLayout {
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
        case .nameServiceAccounts:
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
        case .accountGeneratedFromQuery(let item, _):
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
        case .nameServiceAccount(let item, _):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountItem: item
            )
        }
    }
}

extension ReceiverAccountSelectionListLayout {
    private func sizeForSearchNoContent(
        _ listView: UICollectionView
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let item = ReceiverAccountSelectionNoContentViewModel()
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
        let sampleAccountPreview = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: nil
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountPreview)
        let newSize = ReceiverAccountSelectionPreviewCell.calculatePreferredSize(
            sampleAccountItem,
            for: ReceiverAccountSelectionPreviewCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: ReceiverAccountSelectionListHeaderViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = ReceiverAccountSelectionListTitleSupplementaryCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(for: listView)
        let newSize = ReceiverAccountSelectionListTitleSupplementaryCell.calculatePreferredSize(
            item,
            for: ReceiverAccountSelectionListTitleSupplementaryCell.theme,
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
        let sizeCacheIdentifier = ReceiverAccountSelectionPreviewCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let sampleAccountPreview = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-unknown".localized
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountPreview)
        let newSize = ReceiverAccountSelectionPreviewCell.calculatePreferredSize(
            sampleAccountItem,
            for: ReceiverAccountSelectionPreviewCell.theme,
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
        let sizeCacheIdentifier = ReceiverAccountSelectionListContactCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width

        let newSize = ReceiverAccountSelectionListContactCell.calculatePreferredSize(
            item,
            for: ReceiverAccountSelectionListContactCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension ReceiverAccountSelectionListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
        listView.contentInset.horizontal -
        sectionHorizontalInsets.leading -
        sectionHorizontalInsets.trailing
    }
}
