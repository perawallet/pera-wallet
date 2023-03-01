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

//   AccountSelectScreenListAPIDataController.swift

import Foundation
import CoreGraphics
import MacaroonUtils
import MacaroonURLImage

final class AccountSelectScreenListAPIDataController:
    AccountSelectScreenListDataController,
    SharedDataControllerObserver {

    var eventHandler: ((AccountSelectScreenListDataControllerEvent) -> Void)?

    var lastSnapshot: Snapshot?

    subscript(address: String?) -> AccountHandle? {
        return nil
    }

    private let sharedDataController: SharedDataController
    private let api: ALGAPI

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.oldSelectAccount.updates",
        qos: .userInitiated
    )
    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    private var _contacts: [Contact] = []
    private var contacts: [Contact] = []
    private var isContactsFetched: Bool = false

    private var _accounts: [AccountHandle] = []
    private var accounts: [AccountHandle] = []
    private var matchedAccounts: [NameService] = []
    private var searchedAccounts: [AccountHandle] = []

    private var searchQuery: String?

    private var nameServiceAPIStatus: NameServiceAPIStatus = .idle

    init(
        _ sharedDataController: SharedDataController,
        api: ALGAPI
    ) {
        self.sharedDataController = sharedDataController
        self.api = api
    }

    deinit {
        sharedDataController.remove(self)
    }
}

/// <mark> API
extension AccountSelectScreenListAPIDataController {
    func load() {
        fetchContacts()
        sharedDataController.add(self)
        deliverInitialSnapshot()
    }

    func reload() {
        deliverContentSnapshot()
    }

    func search(query: String?) {
        searchThrottler.performNext {
            [weak self] in

            guard let self = self else {
                return
            }

            self.searchQuery = query
            self.searchNameService(query: query)

            self.reload()
        }
    }

    func account(at indexPath: IndexPath) -> Account? {
        let index = indexPath.item.advanced(by: -1)
        return accounts[safe: index]?.value
    }

    func contact(at indexPath: IndexPath) -> Contact? {
        let index = indexPath.item.advanced(by: -1)
        return contacts[safe: index]
    }

    func searchedAccount(at indexPath: IndexPath) -> Account? {
        let index = indexPath.item.advanced(by: -1)
        return searchedAccounts[safe: index]?.value
    }

    func matchedAccount(at indexPath: IndexPath) -> NameService? {
        let index = indexPath.item.advanced(by: -1)
        return matchedAccounts[safe: index]
    }
}

/// <mark> SharedDataControllerObserver
extension AccountSelectScreenListAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialSnapshot()
        case .didStartRunning(let isFirst):
            if isFirst ||
               lastSnapshot == nil {
                deliverInitialSnapshot()
            }
        case .didFinishRunning:
            reload()
        }
    }
}

/// <mark> Diffable Data Source Snapshot
extension AccountSelectScreenListAPIDataController {
    private func deliverInitialSnapshot() {
        if !sharedDataController.isPollingAvailable {
            deliverNoContentSnapshot()
        } else {
            deliverContentSnapshot()
        }
    }

    private func deliverContentSnapshot() {
        self._accounts = sharedDataController.sortedAccounts()

        self.filterAccounts()

        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()
            self.appendMatchedAccountsTo(snapshot: &snapshot)
            self.appendAccountsTo(snapshot: &snapshot)
            self.appendContactsTo(snapshot: &snapshot)
            self.appendSearchAccountsTo(snapshot: &snapshot)
            self.appendNoContentIfNeededTo(snapshot: &snapshot)

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent(AccountSelectNoContentViewModel(hasBody: true)))],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.publish(.didUpdate(snapshot()))
        }
    }
}

/// <mark> Snapshot Helpers
extension AccountSelectScreenListAPIDataController {
    private func appendMatchedAccountsTo(snapshot: inout Snapshot) {
        switch nameServiceAPIStatus {
        case .searching:
            let headerItem: AccountSelectAccountItem = .header(SelectAccountHeaderViewModel(.matchedAccounts))
            snapshot.appendSections([.matched])
            snapshot.appendItems([.account(headerItem), .empty(.loading)], toSection: .matched)
            return
        case .idle:
            return
        case .finished:
            break
        }

        let headerItem: AccountSelectAccountItem = .header(SelectAccountHeaderViewModel(.matchedAccounts))

        if !self.matchedAccounts.isEmpty {
            var accountItems = self.matchedAccounts.map { nameService -> AccountSelectItem in
                let imageSource = DefaultURLImageSource(url: URL(string: nameService.service.logo))
                let nameServiceAccount = nameService.account.value
                let preview = NameServiceAccountListItem(
                    address: nameServiceAccount.address,
                    icon: imageSource,
                    title: nameServiceAccount.address.shortAddressDisplay,
                    subtitle: nameService.name
                )
                return .account(.matchedAccountCell(AccountListItemViewModel(preview)))
            }

            accountItems.insert(
                .account(headerItem),
                at: 0
            )

            snapshot.appendSections([.matched])
            snapshot.appendItems(
                accountItems,
                toSection: .matched
            )
        } else {
            snapshot.appendSections([.matched])
            snapshot.appendItems([
                .account(headerItem),
                .empty(.noContent(AccountSelectNoContentViewModel(hasBody: true)))
            ], toSection: .matched)
        }
    }

    private func appendAccountsTo(snapshot: inout Snapshot) {
        if !self.accounts.isEmpty {
            var accountItems = self.accounts.map { accountHandle -> AccountSelectItem in
                let account = accountHandle.value
                let accountNameViewModel = AuthAccountNameViewModel(account)
                let item = CustomAccountListItem(
                    accountNameViewModel,
                    address: account.address
                )
                return .account(.accountCell(AccountListItemViewModel(item)))
            }

            let headerItem: AccountSelectAccountItem = .header(SelectAccountHeaderViewModel(.accounts))
            accountItems.insert(
                .account(headerItem),
                at: 0
            )

            snapshot.appendSections([.accounts])
            snapshot.appendItems(
                accountItems,
                toSection: .accounts
            )
        }
    }

    private func appendContactsTo(snapshot: inout Snapshot) {
        guard isContactsFetched else {
            let headerItem: AccountSelectAccountItem = .header(SelectAccountHeaderViewModel(.contacts))
            snapshot.appendSections([.contacts])
            snapshot.appendItems([.account(headerItem), .empty(.loading)], toSection: .contacts)

            return
        }

        if !self.contacts.isEmpty {
            let theme = SelectContactViewTheme()

            var contactItems = self.contacts.map { contact -> AccountSelectItem in
                let viewModel = ContactsViewModel(
                    contact: contact,
                    imageSize: CGSize(width: theme.imageSize.w, height: theme.imageSize.h)
                )
                return .account(.contactCell(viewModel))
            }

            let headerItem: AccountSelectAccountItem = .header(SelectAccountHeaderViewModel(.contacts))
            contactItems.insert(
                .account(headerItem),
                at: 0
            )

            snapshot.appendSections([.contacts])
            snapshot.appendItems(
                contactItems,
                toSection: .contacts
            )
        }
    }

    private func appendSearchAccountsTo(snapshot: inout Snapshot) {
        if !self.searchedAccounts.isEmpty {
            var accountItems = self.searchedAccounts.map { accountHandle -> AccountSelectItem in
                let account = accountHandle.value
                let accountNameViewModel = AuthAccountNameViewModel(accountHandle.value)
                let item = CustomAccountListItem(
                    accountNameViewModel,
                    address: account.address
                )
                return .account(.searchAccountCell(AccountListItemViewModel(item)))
            }

            let headerItem: AccountSelectAccountItem = .header(SelectAccountHeaderViewModel(.search))
            accountItems.insert(
                .account(headerItem),
                at: 0
            )

            snapshot.appendSections([.searchResult])
            snapshot.appendItems(
                accountItems,
                toSection: .searchResult
            )
        }
    }

    private func appendNoContentIfNeededTo(snapshot: inout Snapshot) {
        guard
            nameServiceAPIStatus == .idle,
            self.contacts.isEmpty,
            self.accounts.isEmpty,
            self.matchedAccounts.isEmpty,
            self.searchedAccounts.isEmpty
        else {
            return
        }
        deliverNoContentSnapshot()
    }
}

extension AccountSelectScreenListAPIDataController {
    private func publish(
        _ event: AccountSelectScreenListDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

/// <mark> Helpers
extension AccountSelectScreenListAPIDataController {
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }

                self._contacts = results
            default:
                break
            }

            self.isContactsFetched = true

            self.reload()
        }
    }

    private func filterAccounts() {
        guard let searchKeyword = searchQuery, !searchKeyword.isEmptyOrBlank else {
            self.accounts = _accounts
            self.contacts = _contacts
            self.searchedAccounts = []
            return
        }

        let filteredAccounts = _accounts.filter { account in
            (account.value.name?.containsCaseInsensitive(searchKeyword) ?? false) ||
            (account.value.address.containsCaseInsensitive(searchKeyword))
        }

        let filteredContacts = contacts.filter { contact in
            (contact.name?.containsCaseInsensitive(searchKeyword) ?? false) ||
            (contact.address?.containsCaseInsensitive(searchKeyword) ?? false)
        }

        var searchedAccounts: [AccountHandle] = []
        if filteredAccounts.isEmpty && filteredContacts.isEmpty && searchKeyword.isValidatedAddress {
            searchedAccounts = [
                AccountHandle(account: Account(address: searchKeyword, type: .standard), status: .idle)
            ]
        }

        self.searchedAccounts = searchedAccounts
        self.accounts = filteredAccounts
        self.contacts = filteredContacts
    }
}

/// <mark>: NFDomain Search
extension AccountSelectScreenListAPIDataController {
    private func searchNameService(query: String?) {
        self.matchedAccounts = []

        guard let searchQuery = query, !searchQuery.isEmptyOrBlank, searchQuery.containsNameService else {
            nameServiceAPIStatus = .idle
            return
        }

        nameServiceAPIStatus = .searching

        api.fetchNameServices(NameServiceQuery(name: searchQuery)) {
            [weak self] result in
            guard let self = self else { return }

            self.nameServiceAPIStatus = .finished

            switch result {
            case .success(let nameServiceList):
                self.matchedAccounts = nameServiceList.results
                self.reload()
            case .failure:
                return
            }
        }
    }
}

enum NameServiceAPIStatus {
    case idle
    case searching
    case finished
}
