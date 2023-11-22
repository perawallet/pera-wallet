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

//   WCSessionDetailLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSessionDetailLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let dataSource: WCSessionDetailDataSource
    private let dataController: WCSessionDetailDataController?

    init(
        dataSource: WCSessionDetailDataSource,
        dataController: WCSessionDetailDataController?
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

extension WCSessionDetailLayout {
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
        case .profile: return .init(top: 12, left: 24, bottom: 0, right: 24)
        case .wcV1Badge: return .init(top: 0, left: 24, bottom: 0, right: 24)
        case .connectionInfo: return .init(top: 28, left: 24, bottom: 28, right: 24)
        case .connectedAccounts: return .init(top: 8, left: 0, bottom: 28, right: 0)
        case .advancedPermissions: return .init(top: 4, left: 24, bottom: 0, right: 24)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section],
              listSection == .connectedAccounts,
              let item = dataController?.sessionConnectedAccountsHeaderViewModel else {
            return CGSize((collectionView.bounds.width, 0))
        }

        let size = listView(
            collectionView,
            layout: collectionViewLayout,
            sizeForConnectedAccountsHeaderItem: item,
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
        case .connectionInfo:
            guard let item = dataController?.sessionInfoViewModel else {
                return .zero
            }

            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForConnectionInfoItem: item,
                at: indexPath
            )
        case .wcV1Badge:
            guard let item = dataController?.wcV1SessionBadgeViewModel else {
                return .zero
            }

            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForWCV1BadgeItem: item,
                at: indexPath
            )
        case .connectedAccount(let item):
            guard let item = dataController?[item.address] else {
                return .zero
            }

            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForConnectedAccountItem: item,
                at: indexPath
            )
        case .advancedPermission(let item):
            switch item {
            case .header:
                guard let item = dataController?.sessionAdvancedPermissionsHeaderViewModel else {
                    return .zero
                }

                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForAdvancedPermissionsHeaderItem: item,
                    at: indexPath
                )
            case .cell(let item):
                guard let item = dataController?[item.permission] else {
                    return .zero
                }

                return listView(
                    collectionView,
                    layout: collectionViewLayout,
                    sizeForAdvancedPermissionCellItem: item,
                    at: indexPath
                )
            }
        }
    }
}

extension WCSessionDetailLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForProfileItem item: WCSessionProfileViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let cacheIdentifier = WCSessionProfileCell.reuseIdentifier

        if let cachedSize = sizeCache[cacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCSessionProfileCell.calculatePreferredSize(
            item,
            for: WCSessionProfileCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[cacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForWCV1BadgeItem item: WCV1SessionBadgeViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let sizeCacheIdentifier = WCV1SessionBadgeCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCV1SessionBadgeCell.calculatePreferredSize(
            item,
            for: WCV1SessionBadgeCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForConnectionInfoItem item: WCSessionInfoViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let cacheIdentifier = WCSessionInfoCell.reuseIdentifier

        if let cachedSize = sizeCache[cacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCSessionInfoCell.calculatePreferredSize(
            item,
            for: WCSessionInfoCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[cacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForConnectedAccountsHeaderItem item: WCSessionConnectedAccountsHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = WCSessionConnectedAccountsHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let size = WCSessionConnectedAccountsHeader.calculatePreferredSize(
            item,
            for: WCSessionConnectedAccountsHeader.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForConnectedAccountItem item: AccountListItemViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let sizeCacheIdentifier = WCSessionConnectedAccountListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCSessionConnectedAccountListItemCell.calculatePreferredSize(
            item,
            for: WCSessionConnectedAccountListItemCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAdvancedPermissionsHeaderItem item: WCSessionAdvancedPermissionsHeaderViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let sizeCacheIdentifier = WCSessionAdvancedPermissionsHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        let size = WCSessionAdvancedPermissionsHeader.calculatePreferredSize(
            item,
            for: WCSessionAdvancedPermissionsHeader.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )

        sizeCache[sizeCacheIdentifier] = size

        return size
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAdvancedPermissionCellItem item: PrimaryTitleViewModel,
        at indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return WCSessionAdvancedPermissionCell.calculatePreferredSize(
            item,
            for: WCSessionAdvancedPermissionCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
    }
}

extension WCSessionDetailLayout {
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
