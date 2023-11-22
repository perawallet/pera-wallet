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

//   WCSessionDetailLocalDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class WCSessionDetailLocalDataController: WCSessionDetailDataController {
    var eventHandler: EventHandler?

    private lazy var updatesQueue = makeUpdatesQueue()

    /// <todo>
    /// We can have some sort of UI cache and manage it outside of the scope of this type.
    private(set) var sessionProfileViewModel: WCSessionProfileViewModel?
    private(set) lazy var wcV1SessionBadgeViewModel: WCV1SessionBadgeViewModel? = .init()
    var sessionInfoViewModel: WCSessionInfoViewModel?

    private(set) var sessionConnectedAccountsHeaderViewModel: WCSessionConnectedAccountsHeaderViewModel?

    private var connectedAccountListItemViewModelsCache: [PublicKey: AccountListItemViewModel] = [:]

    private(set) var sessionAdvancedPermissionsHeaderViewModel: WCSessionAdvancedPermissionsHeaderViewModel?

    private var wcSessionSupportedMethodsAdvancedPermissionViewModel: WCSessionSupportedMethodsAdvancedPermissionViewModel?
    private var wcSessionSupportedEventsAdvancedPermissionViewModel: WCSessionSupportedEventsAdvancedPermissionViewModel?

    private let sharedDataController: SharedDataController
    private let wcV2SessionConnectionDate: Date?
    private let draft: WCSessionDraft

    init(
        sharedDataController: SharedDataController,
        walletConnectV2Protocol: WalletConnectV2Protocol,
        draft: WCSessionDraft
    ) {
        self.sharedDataController = sharedDataController
        self.wcV2SessionConnectionDate = draft.wcV2Session.unwrap {
            let connectionDates = walletConnectV2Protocol.getConnectionDates()
            return connectionDates[$0.topic]
        }
        self.draft = draft
    }

    subscript(address: PublicKey) -> AccountListItemViewModel? {
        return findViewModel(forAddress:  address)
    }

    subscript(permission: WCSessionDetailAdvancedPermission) -> PrimaryTitleViewModel? {
        return findViewModel(forPermission: permission)
    }
}

extension WCSessionDetailLocalDataController {
    func load() {
        updatesQueue.async {
            [weak self] in
            guard let self else { return }

            deliverUpdatesForProfile()
            deliverUpdatesForWCV1BadgeIfNeeded()
            deliverUpdatesForConnectionInfo()
            deliverUpdatesForConnectedAccounts()
            deliverUpdatesForAdvancedPermissions()
        }
    }
}

extension WCSessionDetailLocalDataController {
    func getSessionDraft() -> WCSessionDraft {
        return draft
    }

    func getDappURL() -> URL? {
        if let wcV1Session = draft.wcV1Session {
            return wcV1Session.peerMeta.url
        }

        if let wcV2Session = draft.wcV2Session {
            return URL(string: wcV2Session.peer.url)
        }

        return nil
    }
}

extension WCSessionDetailLocalDataController {
    var isPrimaryActionEnabled: Bool {
        /// <note> Session expiry date extendability is disabled for now. Date: 05.09.2023
        return true
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForProfile() {
        var snapshot = SectionSnapshot()
        appendItemsForProfile(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .profile
        )
        publishUpdates(update)
    }

    private func appendItemsForProfile(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForProfile()
        snapshot.append(items)
    }

    private func makeItemsForProfile() -> [ItemIdentifier] {
        sessionProfileViewModel = WCSessionProfileViewModel(draft)
        return [ .profile ]
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForWCV1BadgeIfNeeded() {
        guard draft.isWCv1Session else {  return }

        var snapshot = SectionSnapshot()
        appendItemsForWCV1Badge(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .wcV1Badge
        )
        publishUpdates(update)
    }

    private func appendItemsForWCV1Badge(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForWCV1Badge()
        snapshot.append(items)
    }

    private func makeItemsForWCV1Badge() -> [ItemIdentifier] {
        wcV1SessionBadgeViewModel = WCV1SessionBadgeViewModel()
        return [ .wcV1Badge ]
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForConnectionInfo() {
        var snapshot = SectionSnapshot()
        appendItemsForConnectionInfo(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .connectionInfo
        )
        publishUpdates(update)
    }

    private func appendItemsForConnectionInfo(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForConnectionInfo()
        snapshot.append(items)
    }

    private func makeItemsForConnectionInfo() -> [ItemIdentifier] {
        sessionInfoViewModel = WCSessionInfoViewModel(
            draft: draft,
            wcV2SessionConnectionDate: wcV2SessionConnectionDate
        )
        return [ .connectionInfo ]
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForConnectedAccounts() {
        sessionConnectedAccountsHeaderViewModel = .init()

        var snapshot = SectionSnapshot()
        appendItemsForConnectedAccounts(into: &snapshot)

        guard snapshot.items.isNonEmpty else { return }

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .connectedAccounts
        )
        publishUpdates(update)
    }

    private func appendItemsForConnectedAccounts(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForConnectedAccounts()
        snapshot.append(items)
    }

    private func makeItemsForConnectedAccounts() -> [ItemIdentifier] {
        let accounts = getConnectedAccounts()
        return accounts.map { .connectedAccount(makeItem(for: $0)) }
    }

    private func getConnectedAccounts() -> [AccountHandle] {
        var accounts: [AccountHandle] = []

        if let wcV1Session = draft.wcV1Session {
            accounts = getConnectedAccountsForWCv1(wcV1Session)
        }

        if let wcV2Session = draft.wcV2Session {
            accounts = getConnectedAccountsForWCv1(wcV2Session)
        }

        return accounts
    }

    private func getConnectedAccountsForWCv1(_ wcV1Session: WCSession) -> [AccountHandle] {
        let sessionAccounts = wcV1Session.walletMeta?.accounts
        let localAccounts: [AccountHandle] = sessionAccounts?.compactMap {
            let account = sharedDataController.accountCollection[$0]
            return account
        } ?? []

        let sortedAccounts = sharedDataController.selectedAccountSortingAlgorithm.unwrap { accountSortingAlgorithm in
            localAccounts.sorted(by: accountSortingAlgorithm.getFormula)
        }
       return sortedAccounts ?? localAccounts
    }

    private func getConnectedAccountsForWCv1(_ wcV2Session: WalletConnectV2Session) -> [AccountHandle] {
        var sessionAccounts = Set<String>()
        let localAccounts = wcV2Session.accounts.compactMap {
            let address = $0.address
            if sessionAccounts.insert(address).inserted {
                let localAccount = sharedDataController.accountCollection[address]
                return localAccount
            }

            return nil
        }

        let sortedAccounts = sharedDataController.selectedAccountSortingAlgorithm.unwrap { accountSortingAlgorithm in
            localAccounts.sorted(by: accountSortingAlgorithm.getFormula)
        }
        return sortedAccounts ?? localAccounts
    }

    private func makeItem(for account: AccountHandle) -> WCSessionDetail.ConnectedAccountItem {
        saveToCache(account)
        return .init(address: account.value.address)
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForAdvancedPermissions() {
        var snapshot = SectionSnapshot()
        appendItemsForAdvancedPermissions(into: &snapshot)

        guard snapshot.items.isNonEmpty else { return }

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .advancedPermissions
        )
        publishUpdates(update)
    }

    private func appendItemsForAdvancedPermissions(into snapshot: inout SectionSnapshot) {
        let cellItems = makeItemsForAdvancedPermissionCells()

        guard cellItems.isNonEmpty else { return }

        let headerItem = makeItemsForAdvancedPermissionHeader()
        snapshot.append([headerItem])

        snapshot.append(
            cellItems,
            to: headerItem
        )
    }

    private func makeItemsForAdvancedPermissionHeader() -> ItemIdentifier {
        sessionAdvancedPermissionsHeaderViewModel = .init()
        return .advancedPermission(.header)
    }

    private func makeItemsForAdvancedPermissionCells() -> [ItemIdentifier] {
        if draft.isWCv1Session {
            return makeItemsForWCv1AdvancedPermissionCells()
        }

        if draft.isWCv2Session {
            return makeItemsForWCv2AdvancedPermissionCells()
        }

        return []
    }

    private func makeItemsForWCv1AdvancedPermissionCells() -> [ItemIdentifier] {
        var permissions: [WCSessionDetailAdvancedPermission] = []

        let supportedMethods = WCSession.supportedMethods
        wcSessionSupportedMethodsAdvancedPermissionViewModel = .init(supportedMethods)
        permissions.append(.supportedMethods)

        let supportedEvents = WCSession.supportedEvents
        wcSessionSupportedEventsAdvancedPermissionViewModel = .init(supportedEvents)
        permissions.append(.supportedEvents)

        return permissions.map { .advancedPermission(makeItem(for: $0)) }
    }

    private func makeItemsForWCv2AdvancedPermissionCells() -> [ItemIdentifier] {
        var permissions: [WCSessionDetailAdvancedPermission] = []

        let requiredNamespaces = draft.wcV2Session?.requiredNamespaces[WalletConnectNamespaceKey.algorand]

        let supportedMethods = requiredNamespaces?.methods ?? []
        if !supportedMethods.isEmpty {
            wcSessionSupportedMethodsAdvancedPermissionViewModel = .init(supportedMethods)

            permissions.append(.supportedMethods)
        }

        let supportedEvents = requiredNamespaces?.events ?? []
        if !supportedEvents.isEmpty {
            wcSessionSupportedEventsAdvancedPermissionViewModel = .init(supportedEvents)

            permissions.append(.supportedEvents)
        }

        return permissions.map { .advancedPermission(makeItem(for: $0)) }
    }

    private func makeItem(for permission: WCSessionDetailAdvancedPermission) -> WCSessionDetail.AdvancedPermissionItem {
        return .cell(.init(permission: permission))
    }
}

extension WCSessionDetailLocalDataController {
    private func publishUpdates(_ update: SectionSnapshotUpdate?) {
        guard let update else { return }

        publish(event: .didUpdate(update))
    }

    private func publish(event: WCSessionDetailDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }
            self.eventHandler?(event)
        }
    }
}

extension WCSessionDetailLocalDataController {
    private func findViewModel(forAddress address: PublicKey) -> AccountListItemViewModel? {
        return connectedAccountListItemViewModelsCache[address]
    }

    private func saveToCache(_ connectedAccount: AccountHandle) {
        let item = WCSessionDetailConnectedAccountItem(
            account: connectedAccount,
            session: draft
        )
        connectedAccountListItemViewModelsCache[connectedAccount.value.address] = AccountListItemViewModel(item)
    }
}

extension WCSessionDetailLocalDataController {
    private func findViewModel(forPermission permission: WCSessionDetailAdvancedPermission) -> PrimaryTitleViewModel? {
        switch permission {
        case .supportedMethods: return wcSessionSupportedMethodsAdvancedPermissionViewModel
        case .supportedEvents: return wcSessionSupportedEventsAdvancedPermissionViewModel
        }
    }
}

extension WCSessionDetailLocalDataController {
    private func makeUpdatesQueue() -> DispatchQueue {
        let queue = DispatchQueue(
            label: "pera.queue.wcSessionDetail.updates",
            qos: .userInitiated
        )
        return queue
    }
}
