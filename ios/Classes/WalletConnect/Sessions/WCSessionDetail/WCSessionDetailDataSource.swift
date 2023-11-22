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

//   WCSessionDetailDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSessionDetailDataSource: UICollectionViewDiffableDataSource<
WCSessionDetail.SectionIdentifier,
WCSessionDetail.ItemIdentifier
> {
    init(
        collectionView: UICollectionView,
        dataController: WCSessionDetailDataController?
    ) {
        let profileCellRegistration = Self.makeWCSessionProfileCellRegistration()
        let wcV1BadgeCellRegistration = Self.makeWCSessionWCV1SessionBadgeCellRegistration()
        let infoCellRegistration = Self.makeWCSessionInfoCellRegistration()
        let connectedAccountCellRegistration = Self.makeWCSessionConnectedAccountCellRegistration()
        let advancedPermissionHeaderRegistration = Self.makeAdvancedPermissionHeaderRegistration()
        let advancedPermissionCellRegistration = Self.makeWCSessionAdvancedPermissionCellRegistration()

        super.init(collectionView: collectionView) {
            [weak dataController] collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .profile:
                guard let item = dataController?.sessionProfileViewModel else {
                    preconditionFailure("sessionProfileViewModel should be set.")
                }

                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: profileCellRegistration,
                    for: indexPath,
                    item: item
                )
                return cell
            case .wcV1Badge:
                guard let item = dataController?.wcV1SessionBadgeViewModel else {
                    preconditionFailure("wcV1SessionBadgeViewModel should be set.")
                }

                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: wcV1BadgeCellRegistration,
                    for: indexPath,
                    item: item
                )
                return cell
            case .connectionInfo:
                guard let item = dataController?.sessionInfoViewModel else {
                    preconditionFailure("sessionInfoViewModel should be set.")
                }

                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: infoCellRegistration,
                    for: indexPath,
                    item: item
                )
                return cell
            case .connectedAccount(let item):
                guard let item = dataController?[item.address] else {
                    preconditionFailure("connectedAccount should be set.")
                }

                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: connectedAccountCellRegistration,
                    for: indexPath,
                    item: item
                )
                return cell
            case .advancedPermission(let item):
                switch item {
                case .header:
                    guard let item = dataController?.sessionAdvancedPermissionsHeaderViewModel else {
                        preconditionFailure("sessionAdvancedPermissionsHeaderViewModel should be set.")
                    }

                    let cell = collectionView.dequeueConfiguredReusableCell(
                        using: advancedPermissionHeaderRegistration,
                        for: indexPath,
                        item: item
                    )
                    return cell
                case .cell(let item):
                    guard let item = dataController?[item.permission] else {
                        preconditionFailure("advancedPermissionCell should be set.")
                    }

                    let cell = collectionView.dequeueConfiguredReusableCell(
                        using: advancedPermissionCellRegistration,
                        for: indexPath,
                        item: item
                    )
                    return cell
                }
            }
        }

        let wcSessionConnectedAccountsHeaderRegistration =
            Self.makeWCSessionConnectedAccountsHeaderRegistration(dataController)

        supplementaryViewProvider = {
            [weak self] collectionView, kind, indexPath in
            guard let section = self?.snapshot().sectionIdentifiers[safe: indexPath.section],
                  section == .connectedAccounts,
                  kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            let header = collectionView.dequeueConfiguredReusableSupplementary(
                using: wcSessionConnectedAccountsHeaderRegistration,
                for: indexPath
            )
            return header
        }
    }
}

extension WCSessionDetailDataSource {
    typealias WCSessionProfileCellRegistration = UICollectionView.CellRegistration<WCSessionProfileCell, WCSessionProfileViewModel>

    private static func makeWCSessionProfileCellRegistration() -> WCSessionProfileCellRegistration {
        let handler: WCSessionProfileCellRegistration.Handler = { cell, indexPath, item in
            cell.bindData(item)
        }
        return WCSessionProfileCellRegistration(handler: handler)
    }
}

extension WCSessionDetailDataSource {
    typealias WCSessionWCV1SessionBadgeCellRegistration = UICollectionView.CellRegistration<WCV1SessionBadgeCell, WCV1SessionBadgeViewModel>

    private static func makeWCSessionWCV1SessionBadgeCellRegistration() -> WCSessionWCV1SessionBadgeCellRegistration {
        let handler: WCSessionWCV1SessionBadgeCellRegistration.Handler = { cell, indexPath, item in
            cell.bindData(item)
        }
        return WCSessionWCV1SessionBadgeCellRegistration(handler: handler)
    }
}

extension WCSessionDetailDataSource {
    typealias WCSessionInfoCellRegistration = UICollectionView.CellRegistration<WCSessionInfoCell, WCSessionInfoViewModel>

    private static func makeWCSessionInfoCellRegistration() -> WCSessionInfoCellRegistration {
        let handler: WCSessionInfoCellRegistration.Handler = { cell, indexPath, item in
            cell.bindData(item)
        }
        return WCSessionInfoCellRegistration(handler: handler)
    }
}

extension WCSessionDetailDataSource {
    typealias WCSessionConnectedAccountsHeaderRegistration = UICollectionView.SupplementaryRegistration<WCSessionConnectedAccountsHeader>

    private static func makeWCSessionConnectedAccountsHeaderRegistration(
        _ dataController: WCSessionDetailDataController?
    ) -> WCSessionConnectedAccountsHeaderRegistration {
        let handler: WCSessionConnectedAccountsHeaderRegistration.Handler = {
            [weak dataController] header, elementedKind, indexPath in
            let item = dataController?.sessionConnectedAccountsHeaderViewModel
            header.bindData(item)
        }
        return WCSessionConnectedAccountsHeaderRegistration(
            elementKind: UICollectionView.elementKindSectionHeader,
            handler: handler
        )
    }
}

extension WCSessionDetailDataSource {
    typealias WCSessionConnectedAccountCellRegistration = UICollectionView.CellRegistration<WCSessionConnectedAccountListItemCell, AccountListItemViewModel>

    private static func makeWCSessionConnectedAccountCellRegistration() -> WCSessionConnectedAccountCellRegistration {
        let handler: WCSessionConnectedAccountCellRegistration.Handler = { cell, indexPath, item in
            cell.bindData(item)
        }
        return WCSessionConnectedAccountCellRegistration(handler: handler)
    }
}

extension WCSessionDetailDataSource {
    typealias AdvancedPermissionHeaderRegistration = UICollectionView.CellRegistration<WCSessionAdvancedPermissionsHeader, WCSessionAdvancedPermissionsHeaderViewModel>

    private static func makeAdvancedPermissionHeaderRegistration() -> AdvancedPermissionHeaderRegistration {
        return AdvancedPermissionHeaderRegistration { cell, indexPath, item in
            cell.backgroundConfiguration = .clear()
            cell.contentConfiguration = WCSessionAdvancedPermissionsHeaderContentConfiguration(viewModel: item)
        }
    }
}

extension WCSessionDetailDataSource {
    typealias WCSessionAdvancedPermissionCellRegistration = UICollectionView.CellRegistration<WCSessionAdvancedPermissionCell, PrimaryTitleViewModel>

    private static func makeWCSessionAdvancedPermissionCellRegistration() -> WCSessionAdvancedPermissionCellRegistration {
        let handler: WCSessionAdvancedPermissionCellRegistration.Handler = { cell, indexPath, item  in
            cell.bindData(item)
        }
        return WCSessionAdvancedPermissionCellRegistration(handler: handler)
    }
}
