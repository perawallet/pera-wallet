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

//
//   WCSessionListLayout.swift

import UIKit
import MacaroonUIKit

final class WCSessionListLayout: NSObject {
    private let listDataSource: WCSessionListDataSource

    private var sizeCache: [String: CGSize] = [:]

    init(
        listDataSource: WCSessionListDataSource
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

extension WCSessionListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        var insets: UIEdgeInsets = .zero

        switch listSection {
        case .empty:
            return insets
        case .sessions:
            insets.top = 32
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
        case .empty:
            return sizeForEmptyItem(
                collectionView
            )
        case .session(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForSessionCellItem: item.viewModel
            )
        }
    }
}

extension WCSessionListLayout {
    private func sizeForEmptyItem(
        _ listView: UICollectionView
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentWithActionCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let height =
            listView.bounds.height -
            listView.safeAreaTop -
            listView.safeAreaBottom

        let newSize = CGSize((width, height))

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForSessionCellItem item: WCSessionItemViewModel?
    ) -> CGSize {
        let width = listView.bounds.width
        let newSize = WCSessionItemCell.calculatePreferredSize(
            item,
            for: WCSessionItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        return newSize
    }
}
