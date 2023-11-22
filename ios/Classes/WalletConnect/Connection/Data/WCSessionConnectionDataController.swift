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

//   WCSessionConnectionDataController.swift

import Foundation
import UIKit

protocol WCSessionConnectionDataController: AnyObject {
    typealias SectionIdentifier = WCSessionConnection.SectionIdentifier
    typealias ItemIdentifier = WCSessionConnection.ItemIdentifier
    typealias SectionSnapshotUpdate = WCSessionConnection.SectionSnapshotUpdate
    typealias SectionSnapshot = SectionSnapshotUpdate.Snapshot
    typealias EventHandler = (WCSessionConnectionDataControllerEvent) -> Void

    var eventHandler: EventHandler? { get set }

    var hasSingleAccount: Bool { get }

    var isPrimaryActionEnabled: Bool { get }

    func load()

    func getSelectedAccounts() -> [Account]

    typealias Index = Int
    func selectAccountItem(at index: Index)
    func unselectAccountItem(at index: Index)
    func isAccountSelected(at index: Index) -> Bool

    var sessionProfileViewModel: WCSessionConnectionProfileViewModel? { get }

    subscript(sectionForHeader: SectionIdentifier) -> WCSessionConnectionHeaderViewModel? { get }

    subscript(requestedPermission: WCSessionRequestedPermission) -> SecondaryListItemViewModel? { get }

    subscript(accountAddress: PublicKey) -> AccountListItemViewModel? { get }
}

enum WCSessionConnection { }

extension WCSessionConnection {
    enum SectionIdentifier: Hashable {
        case profile
        case requestedPermissions
        case accounts
    }

    enum ItemIdentifier: Hashable {
        case profile
        case requestedPermission(WCSessionRequestedPermission)
        case account(AccountItem)
    }

    struct SectionSnapshotUpdate {
        typealias Snapshot = NSDiffableDataSourceSectionSnapshot<WCSessionConnection.ItemIdentifier>

        let snapshot: Snapshot
        let section: SectionIdentifier
    }
}

extension WCSessionConnection {
    struct AccountItem: Hashable {
        let address: PublicKey
    }
}

enum WCSessionRequestedPermission {
    case network
    case methods
    case events
}

enum WCSessionConnectionDataControllerEvent {
    typealias SectionSnapshotUpdate = WCSessionConnection.SectionSnapshotUpdate

    case didUpdate(SectionSnapshotUpdate)
    case didFinishUpdates
}
