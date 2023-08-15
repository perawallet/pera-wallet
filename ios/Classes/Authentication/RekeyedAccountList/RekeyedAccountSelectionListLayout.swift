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

//   RekeyedAccountSelectionListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyedAccountSelectionListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let listDataSource: RekeyedAccountSelectionListDataSource

    init(
        listDataSource: RekeyedAccountSelectionListDataSource
    ) {
        self.listDataSource = listDataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 16
        return flowLayout
    }
}

extension RekeyedAccountSelectionListLayout {
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
                left: 24,
                bottom: 8,
                right: 24
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
        case .accountLoading:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForLoadingItemAt: indexPath
            )
        }
    }
}

extension RekeyedAccountSelectionListLayout {
    private func listView(
        _ listView: UICollectionView,
        sizeForHeaderItem item: RekeyedAccountSelectionListHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = RekeyedAccountSelectionListHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let newSize = RekeyedAccountSelectionListHeader.calculatePreferredSize(
            item,
            for: RekeyedAccountSelectionListHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForLoadingItemAt indexPath: IndexPath
    ) -> CGSize {
        let sizeCacheIdentifier = RekeyedAccountSelectionListAccountLoadingCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            for: listView,
            forSectionAt: indexPath.section
        )
        let newSize = RekeyedAccountSelectionListAccountLoadingCell.calculatePreferredSize(
            for: RekeyedAccountSelectionListAccountLoadingCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: RekeyedAccountSelectionListAccountCellItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = RekeyedAccountSelectionListAccountCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        )
        let newSize = RekeyedAccountSelectionListAccountCell.calculatePreferredSize(
            item.viewModel,
            for: RekeyedAccountSelectionListAccountCell.theme.context,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension RekeyedAccountSelectionListLayout {
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
