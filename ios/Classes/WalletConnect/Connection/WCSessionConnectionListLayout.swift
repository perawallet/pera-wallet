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

//   WCSessionConnectionListLayout.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSessionConnectionListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]
    
    private let dataSource: WCSessionConnectionDataSource
    private let dataController: WCSessionConnectionDataController?

    init(
        dataSource: WCSessionConnectionDataSource,
        dataController: WCSessionConnectionDataController?
    ) {
        self.dataSource = dataSource
        self.dataController = dataController
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        return flowLayout
    }
}

extension WCSessionConnectionListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .profile: return .init(top: 32, left: 24, bottom: 32, right: 24)
        case .requestedPermissions: return .init(top: 0, left: 24, bottom: 32, right: 24)
        case .accounts: return .init(top: 8, left: 0, bottom: 0, right: 0)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section],
              let item = dataController?[listSection] else {
            return CGSize((collectionView.bounds.width, 0))
        }

        let size = listView(
            collectionView,
            layout: collectionViewLayout,
            sizeForHeaderItem: item,
            atSection: section
        )
        return size
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .profile:
            guard let item = dataController?.sessionProfileViewModel else {
                return .zero
            }

            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForProfileItem: item,
                at: indexPath
            )
        case .requestedPermission(let item):
            guard let item = dataController?[item] else {
                return .zero
            }

            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForRequestedPermissionItem: item,
                at: indexPath
            )
        case .account(let item):
            guard let item = dataController?[item.address] else {
                return .zero
            }

            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountItem: item,
                at: indexPath
            )
        }
    }
}

extension WCSessionConnectionListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForProfileItem item: WCSessionConnectionProfileViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let cacheIdentifier = WCSessionConnectionProfileCell.reuseIdentifier

        if let cachedSize = sizeCache[cacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCSessionConnectionProfileCell.calculatePreferredSize(
            item,
            for: WCSessionConnectionProfileCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[cacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForHeaderItem item: WCSessionConnectionHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = WCSessionConnectionHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let size = WCSessionConnectionHeader.calculatePreferredSize(
            item,
            for: WCSessionConnectionHeader.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForRequestedPermissionItem item: SecondaryListItemViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let cacheIdentifier = WCSessionRequestedPermissionItemCell.reuseIdentifier

        if let cachedSize = sizeCache[cacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCSessionRequestedPermissionItemCell.calculatePreferredSize(
            item,
            for: WCSessionRequestedPermissionItemCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[cacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountItem item: AccountListItemViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let sizeCacheIdentifier = WCSessionConnectionAccountCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCSessionConnectionAccountCell.calculatePreferredSize(
            item,
            for: WCSessionConnectionAccountCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }
}

extension WCSessionConnectionListLayout {
    private func calculateContentWidth(
        _ listView: UICollectionView,
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
