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

//   WCSessionDetailDataController.swift

import Foundation
import UIKit

protocol WCSessionDetailDataController: AnyObject {
    typealias SectionIdentifier = WCSessionDetail.SectionIdentifier
    typealias ItemIdentifier = WCSessionDetail.ItemIdentifier
    typealias SectionSnapshotUpdate = WCSessionDetail.SectionSnapshotUpdate
    typealias SectionSnapshot = SectionSnapshotUpdate.Snapshot
    typealias EventHandler = (WCSessionDetailDataControllerEvent) -> Void

    var eventHandler: EventHandler? { get set }

    var isPrimaryActionEnabled: Bool { get }

    func load()
    func getSessionDraft() -> WCSessionDraft
    func getDappURL() -> URL?

    var sessionProfileViewModel: WCSessionProfileViewModel? { get }
    var wcV1SessionBadgeViewModel: WCV1SessionBadgeViewModel? { get }
    var sessionInfoViewModel: WCSessionInfoViewModel? { get set }

    var sessionConnectedAccountsHeaderViewModel: WCSessionConnectedAccountsHeaderViewModel? { get }
    subscript(connectedAccountAddress: PublicKey) -> AccountListItemViewModel? { get }

    var sessionAdvancedPermissionsHeaderViewModel: WCSessionAdvancedPermissionsHeaderViewModel? { get }
    subscript(permission: WCSessionDetailAdvancedPermission) -> PrimaryTitleViewModel? { get }
}

enum WCSessionDetail { }

extension WCSessionDetail {
    enum SectionIdentifier: Hashable {
        case profile
        case wcV1Badge
        case connectionInfo
        case connectedAccounts
        case advancedPermissions
    }

    enum ItemIdentifier: Hashable {
        case profile
        case wcV1Badge
        case connectionInfo
        case connectedAccount(ConnectedAccountItem)
        case advancedPermission(AdvancedPermissionItem)
    }

    struct SectionSnapshotUpdate {
        typealias Snapshot = NSDiffableDataSourceSectionSnapshot<WCSessionDetail.ItemIdentifier>

        let snapshot: Snapshot
        let section: SectionIdentifier
    }
}

extension WCSessionDetail {
    struct ConnectedAccountItem: Hashable {
        let address: PublicKey
    }
}

extension WCSessionDetail {
    enum AdvancedPermissionItem: Hashable {
        case header
        case cell(AdvancedPermissionCellItem)
    }

    struct AdvancedPermissionCellItem: Hashable {
        let permission: WCSessionDetailAdvancedPermission
    }
}

enum WCSessionDetailDataControllerEvent {
     typealias SectionSnapshotUpdate = WCSessionDetail.SectionSnapshotUpdate

     case didUpdate(SectionSnapshotUpdate)
 }

enum WCSessionDetailAdvancedPermission {
    case supportedMethods
    case supportedEvents
}
