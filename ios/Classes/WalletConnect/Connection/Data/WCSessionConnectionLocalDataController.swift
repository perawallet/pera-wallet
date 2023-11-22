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

//   WCSessionConnectionLocalDataController.swift

import Foundation
import MacaroonUtils
import OrderedCollections

final class WCSessionConnectionLocalDataController: WCSessionConnectionDataController {
    var eventHandler: EventHandler?

    private lazy var updatesQueue = makeUpdatesQueue()
    
    private lazy var accounts: OrderedDictionary<Index, Account> = [:]
    private lazy var selectedAccounts: OrderedDictionary<Index, Account> = [:]

    private(set) var sessionProfileViewModel: WCSessionConnectionProfileViewModel?

    private var sessionRequestedPermissionsHeaderViewModel: WCSessionConnectionRequestedPermissionsHeaderViewModel?
    private var sessionAccountsHeaderViewModel: WCSessionConnectionSelectAccountHeaderViewModel?
    subscript(sectionForHeader: SectionIdentifier) -> WCSessionConnectionHeaderViewModel? {
        return findViewModel(forSection: sectionForHeader)
    }

    private var sessionNetworkRequestedPermissionViewModel: WCSessionNetworkRequestedPermissionViewModel?
    private var sessionMethodsRequestedPermissionViewModel: WCSessionMethodsRequestedPermissionViewModel?
    private var sessionEventsRequestedPermissionViewModel: WCSessionEventsRequestedPermissionViewModel?

    private(set) var accountListItemViewModelsCache: [PublicKey: AccountListItemViewModel] = [:]

    private let draft: WCSessionConnectionDraft
    private let sharedDataController: SharedDataController

    init(
        draft: WCSessionConnectionDraft,
        sharedDataController: SharedDataController
    ) {
        self.draft = draft
        self.sharedDataController = sharedDataController
    }

    subscript(requestedPermission: WCSessionRequestedPermission) -> SecondaryListItemViewModel? {
        return findViewModel(forRequestedPermission: requestedPermission)
    }

    subscript(accountAddress: PublicKey) -> AccountListItemViewModel? {
        return findViewModel(forAddress: accountAddress)
    }
}

extension WCSessionConnectionLocalDataController {
    var hasSingleAccount: Bool {
        return accounts.isSingular
    }
    
    var isPrimaryActionEnabled: Bool {
        return !selectedAccounts.isEmpty
    }
    
    func getSelectedAccounts() -> [Account] {
        return selectedAccounts.values.elements
    }
    
    func selectAccountItem(at index: Index) {
        guard let selectedAccount = accounts[index] else {
            return
        }
        
        selectedAccounts[index] = selectedAccount
    }
    
    func unselectAccountItem(at index: Index) {
        selectedAccounts[index] = nil
    }
    
    func isAccountSelected(at index: Index) -> Bool {
        return selectedAccounts[index] != nil
    }
}

extension WCSessionConnectionLocalDataController {
    func load() {
        updatesQueue.async {
            [weak self] in
            guard let self else { return }

            deliverUpdatesForProfile()
            deliverUpdatesForRequestedPermissions()
            deliverUpdatesForAccounts()

            publish(event: .didFinishUpdates)
        }
    }
}

extension WCSessionConnectionLocalDataController {
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
        sessionProfileViewModel = WCSessionConnectionProfileViewModel(draft)
        return [ .profile ]
    }
}

extension WCSessionConnectionLocalDataController {
    private func deliverUpdatesForRequestedPermissions() {
        var snapshot = SectionSnapshot()
        appendItemsForAdvancedPermissions(into: &snapshot)

        if snapshot.items.isEmpty { return }

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .requestedPermissions
        )
        publishUpdates(update)
    }

    private func appendItemsForAdvancedPermissions(into snapshot: inout SectionSnapshot) {
       let items = makeItemsForRequestedPermissions()
        snapshot.append(items)
    }

    private func makeItemsForRequestedPermissions() -> [ItemIdentifier] {
        var permissions: [WCSessionRequestedPermission] = []

        if let requestedChains = draft.requestedChains,
           requestedChains.isNonEmpty {
            permissions.append(.network)
        }

        if let supportedEvents = draft.supportedEvents,
           !supportedEvents.isEmpty {
            permissions.append(.events)
        }

        if let supportedMethods = draft.supportedMethods,
           !supportedMethods.isEmpty {
            permissions.append(.methods)
        }

        if permissions.isNonEmpty {
            sessionRequestedPermissionsHeaderViewModel = .init()
        }

        return permissions.map(makeItem(forPermission:))
    }

    private func makeItem(forPermission permission: WCSessionRequestedPermission) -> ItemIdentifier {
        saveToCache(permission)
        return .requestedPermission(permission)
    }
}

extension WCSessionConnectionLocalDataController {
    private func deliverUpdatesForAccounts() {
        var snapshot = SectionSnapshot()
        appendItemsForAccounts(into: &snapshot)

        if snapshot.items.isEmpty { return }

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .accounts
        )
        publishUpdates(update)
    }

    private func appendItemsForAccounts(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForAccounts()
        snapshot.append(items)
    }

    private func makeItemsForAccounts() -> [ItemIdentifier] {
        let filterAlgorithm = AuthorizedAccountListFilterAlgorithm()
        let accounts =
            sharedDataController
                .sortedAccounts()
                .filter(filterAlgorithm.getFormula)

        sessionAccountsHeaderViewModel = .init(isSingle: accounts.isSingular)

        let accountItems = accounts.enumerated().map {
            let account = $0.element
            self.accounts[$0.offset] = account.value
            return ItemIdentifier.account(makeItem(for: account))
        }
        return accountItems
    }

    private func makeItem(for account: AccountHandle) -> WCSessionConnection.AccountItem {
        saveToCache(account)
        return .init(address: account.value.address)
    }
}

extension WCSessionConnectionLocalDataController {
    private func findViewModel(forAddress address: PublicKey) -> AccountListItemViewModel? {
        return accountListItemViewModelsCache[address]
    }

    private func saveToCache(_ account: AccountHandle) {
        let aRawAccount = account.value
        let item = IconWithShortAddressDraft(aRawAccount)
        accountListItemViewModelsCache[aRawAccount.address] = AccountListItemViewModel(item)
    }
}

extension WCSessionConnectionLocalDataController {
    private func findViewModel(forSection section: SectionIdentifier) -> WCSessionConnectionHeaderViewModel? {
        switch section {
        case .requestedPermissions: return sessionRequestedPermissionsHeaderViewModel
        case .accounts: return sessionAccountsHeaderViewModel
        default: return nil
        }
    }
}

extension WCSessionConnectionLocalDataController {
    private func findViewModel(forRequestedPermission permission: WCSessionRequestedPermission) -> SecondaryListItemViewModel? {
        switch permission {
        case .network: return sessionNetworkRequestedPermissionViewModel
        case .methods: return sessionMethodsRequestedPermissionViewModel
        case .events: return sessionEventsRequestedPermissionViewModel
        }
    }

    private func saveToCache(_ permission: WCSessionRequestedPermission) {
        switch permission {
        case .network:
            let requestedChains = draft.requestedChains!
            sessionNetworkRequestedPermissionViewModel = .init(requestedChains)
        case .methods:
            let supportedMethods = draft.supportedMethods!
            sessionMethodsRequestedPermissionViewModel = .init(supportedMethods)
        case .events:
            let supportedEvents = draft.supportedEvents!
            sessionEventsRequestedPermissionViewModel = .init(supportedEvents)
        }
    }
}

extension WCSessionConnectionLocalDataController {
    private func publishUpdates(_ update: SectionSnapshotUpdate?) {
        guard let update else { return }

        publish(event: .didUpdate(update))
    }

    private func publish(event: WCSessionConnectionDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }
            self.eventHandler?(event)
        }
    }
}

extension WCSessionConnectionLocalDataController {
    private func makeUpdatesQueue() -> DispatchQueue {
        let queue = DispatchQueue(
            label: "pera.queue.wcSessionConnection.updates",
            qos: .userInitiated
        )
        return queue
    }
}
