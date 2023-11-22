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

//   WCSessionConnectionDataSource.swift

import UIKit

final class WCSessionConnectionDataSource: UICollectionViewDiffableDataSource<
WCSessionConnection.SectionIdentifier,
WCSessionConnection.ItemIdentifier
> {
    init(
        collectionView: UICollectionView,
        dataController: WCSessionConnectionDataController?
    ) {
        let profileCellRegistration = Self.makeWCSessionProfileCellRegistration()
        let requestedPermissionCellRegistration = Self.makeWCSessionRequestedPermissionCellRegistration()
        let accountCellRegistration = Self.makeWCSessionAccountCellRegistration()

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
            case .requestedPermission(let item): 
                guard let item = dataController?[item] else {
                    preconditionFailure("requestedPermissions should be set.")
                }

                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: requestedPermissionCellRegistration,
                    for: indexPath,
                    item: item
                )
                return cell
            case .account(let item):
                guard let item = dataController?[item.address] else {
                    preconditionFailure("accounts should be set.")
                }

                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: accountCellRegistration,
                    for: indexPath,
                    item: item
                )
                return cell
            }
        }

        let wcSessionConnectionHeaderRegistration =
            Self.makeWCSessionConnectionHeaderRegistration(
                dataController: dataController,
                dataSource: self
            )

        supplementaryViewProvider = {
            [weak self, weak dataController] collectionView, kind, indexPath in
            guard let section = self?.snapshot().sectionIdentifiers[safe: indexPath.section],
                  kind == UICollectionView.elementKindSectionHeader,
                  dataController?[section] != nil else {
                return nil
            }

            let header = collectionView.dequeueConfiguredReusableSupplementary(
                using: wcSessionConnectionHeaderRegistration,
                for: indexPath
            )
            return header
        }
    }
}

extension WCSessionConnectionDataSource {
    typealias WCSessionProfileCellRegistration = UICollectionView.CellRegistration<WCSessionConnectionProfileCell, WCSessionConnectionProfileViewModel>

    private static func makeWCSessionProfileCellRegistration() -> WCSessionProfileCellRegistration {
        let handler: WCSessionProfileCellRegistration.Handler = {
            cell, indexPath, item in
            cell.bindData(item)
        }
        return WCSessionProfileCellRegistration(handler: handler)
    }
}

extension WCSessionConnectionDataSource {
    typealias WCSessionRequestedPermissionRegistration = UICollectionView.CellRegistration<WCSessionRequestedPermissionItemCell, SecondaryListItemViewModel>

    private static func makeWCSessionRequestedPermissionCellRegistration() -> WCSessionRequestedPermissionRegistration {
        let handler: WCSessionRequestedPermissionRegistration.Handler = {
            cell, indexPath, item in
            cell.bindData(item)
        }
        return WCSessionRequestedPermissionRegistration(handler: handler)
    }
}

extension WCSessionConnectionDataSource {
    typealias WCSessionAccountCellRegistration = UICollectionView.CellRegistration<WCSessionConnectionAccountCell, AccountListItemViewModel>

    private static func makeWCSessionAccountCellRegistration() -> WCSessionAccountCellRegistration {
        let handler: WCSessionAccountCellRegistration.Handler = {
            cell, indexPath, item in
            cell.bindData(item)
        }
        return WCSessionAccountCellRegistration(handler: handler)
    }
}

extension WCSessionConnectionDataSource {
    typealias WCSessionConnectionHeaderRegistration = UICollectionView.SupplementaryRegistration<WCSessionConnectionHeader>

    private static func makeWCSessionConnectionHeaderRegistration(
        dataController: WCSessionConnectionDataController?,
        dataSource: WCSessionConnectionDataSource
    ) -> WCSessionConnectionHeaderRegistration {
        let handler: WCSessionConnectionHeaderRegistration.Handler = {
            [weak dataController, weak dataSource] header, elementedKind, indexPath in
            guard
                let section = dataSource?.snapshot().sectionIdentifiers[safe: indexPath.section],
                let item = dataController?[section]
            else {
                header.bindData(nil)
                return
            }

            header.bindData(item)
        }
        return WCSessionConnectionHeaderRegistration(
            elementKind: UICollectionView.elementKindSectionHeader,
            handler: handler
        )
    }
}
