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

//   ReceiverAccountSelectionListAPIDataController.swift

import Foundation
import MacaroonUtils
import CoreGraphics
import MacaroonURLImage
import MacaroonForm
import MagpieCore

final class ReceiverAccountSelectionListAPIDataController:
    ReceiverAccountSelectionListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((ReceiverAccountSelectionListDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?

    private var lastQuery: String?

    private let snapshotQueue: DispatchQueue = .init(
        label: "com.algorand.queue.receiverAccountSelectionListAPIDataController",
        qos: .userInitiated
    )

    private var accounts: [AccountHandle] = []

    private(set) var accountGeneratedFromQuery: Account?

    private var contacts: [Address: Contact] = [:]

    private var ongoingNameServiceEndpoint: EndpointOperatable?
    private var nameServiceAPIStatus: NameServiceAPIStatus = .idle
    private var nameServiceValidator: RegexValidator = .nameService()
    private var matchedAccounts: [NameService] = []

    private lazy var searchThrottler: Throttler = .init(intervalInSeconds: 0.3)

    private let sharedDataController: SharedDataController
    private let api: ALGAPI
    private let addressInputViewText: String?

    init(
        sharedDataController: SharedDataController,
        api: ALGAPI,
        addressInputViewText: String?
    ) {
        self.sharedDataController = sharedDataController
        self.api = api
        self.addressInputViewText = addressInputViewText
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript(accountAddress address: Address) -> Account? {
        return (sharedDataController.accountCollection[address]?.value)
    }

    subscript(contactAddress address: Address) -> Contact? {
        return contacts[address]
    }

    subscript(nameServiceAddress address: Address) -> NameService? {
        return matchedAccounts.first(matching: (\.address, address))
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    func load() {
        deliverLoadingSnapshot()

        sharedDataController.add(self)

        getContacts {
            [weak self] contacts in
            guard let self = self else {
                return
            }

            self.contacts = contacts.reduce(
                into: [Address: Contact]()
            ) { partialResult, contact in
                guard let address = contact.address else {
                    return
                }

                partialResult[address] = contact
            }
        }
    }

    func search(for query: String?) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else {
                return
            }

            self.deliverContentSnapshot(for: query)

            self.fetchNameServiceIfNeeded(for: query)
        }
    }

    func resetSearch() {
        searchThrottler.cancelAll()
        cancelOngoingNameServiceEndpoint()

        deliverContentSnapshot()
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func getContacts(completion: @escaping ([Contact]) -> Void) {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }

                completion(results)
            default:
                completion([])
            }
        }
    }
}

extension ReceiverAccountSelectionListAPIDataController {
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
            sharedDataController.remove(self)

            accounts = sharedDataController.sortedAccounts()

            deliverContentSnapshot(for: lastQuery)
        }
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func deliverInitialSnapshot() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingSnapshot()
        } else {
            deliverNoContentSnapshot()
        }
    }

    private func deliverLoadingSnapshot() {
        deliverSnapshot(isLoading: true) {
            var snapshot = Snapshot()
            snapshot.appendSections([ .loading ])
            snapshot.appendItems(
                [.empty(.loading("1")), .empty(.loading("2"))],
                toSection: .loading
            )
            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([ .empty ])
            snapshot.appendItems(
                [ .empty(.noContent) ],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot(for query: String? = nil) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return nil
            }

            self.lastQuery = query

            var snapshot = Snapshot()

            let contactItems = self.makeContactItems()

            let accountItems = self.makeAccountItems()

            var nameServiceAccountItems: [ReceiverAccountSelectionListItem] = []

            if self.nameServiceAPIStatus == .finished {
                nameServiceAccountItems = self.makeNameServiceItems()
            }

            if accountItems.isEmpty,
               contactItems.isEmpty,
               nameServiceAccountItems.isEmpty {

                if let query = query,
                   query.isValidatedAddress {
                    let accountGeneratedFromQueryItem = self.makeAccountGeneratedFromQueryItem(for: query)

                    self.addAccountGeneratedFromQueryContent(
                        item: accountGeneratedFromQueryItem,
                        &snapshot
                    )
                    return snapshot
                }

                if let preparedQuery = self.prepareQueryForValidation(query),
                    self.isQueryValidNameService(preparedQuery) {

                    if self.nameServiceAPIStatus == .searching {
                        self.addNameServiceSearchingContent(&snapshot)
                        return snapshot
                    }

                    self.addNameServiceNoContent(&snapshot)
                    return snapshot
                }

                self.deliverNoContentSnapshot()
                return nil
            }

            if !contactItems.isEmpty {
                self.addContactContent(
                    items: contactItems,
                    &snapshot
                )
            }

            if !accountItems.isEmpty {
                self.addAccountContent(
                    items: accountItems,
                    &snapshot
                )
            }

            if let preparedQuery = self.prepareQueryForValidation(query),
                self.isQueryValidNameService(preparedQuery) {

                if self.nameServiceAPIStatus == .searching {
                    self.addNameServiceSearchingContent(&snapshot)
                    return snapshot
                }

                if !nameServiceAccountItems.isEmpty {
                    self.addNameServiceContent(
                        items: nameServiceAccountItems,
                        &snapshot
                    )
                } else {
                    self.addNameServiceNoContent(&snapshot)
                }
            }

            return snapshot
        }
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func isContactContainsNameOrAddress(
        _ contact: Contact,
        query: String
    ) -> Bool {
        return contact.name.someString.localizedCaseInsensitiveContains(query)  ||
        contact.address.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAccountContainsNameOrAddress(
        _ account: AccountHandle,
        query: String
    ) -> Bool {
        return account.value.name.someString.localizedCaseInsensitiveContains(query) ||
        account.value.address.localizedCaseInsensitiveContains(query)
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func makeAccountItems() -> [ReceiverAccountSelectionListItem] {
        return accounts.compactMap { account in
            if let query = lastQuery {
                if isAccountContainsNameOrAddress(account, query: query) {
                    return makeAccountItem(account.value)
                }

                return nil
            }

            return makeAccountItem(account.value)
        }
    }

    private func makeAccountItem(_ account: Account) -> ReceiverAccountSelectionListItem {
        let draft = IconWithShortAddressDraft(account)
        let viewModel = AccountListItemViewModel(draft)

        let isPreviouslySelected = addressInputViewText == account.address

        let item: ReceiverAccountSelectionListItem = .account(
            viewModel: viewModel,
            isPreviouslySelected: isPreviouslySelected
        )

        return item
    }

    private func addAccountContent(
        items: [ReceiverAccountSelectionListItem],
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendSections([ .accounts ])

        let headerItem = makeHeaderItem("account-select-header-accounts-title".localized)

        snapshot.appendItems(
            [ headerItem ],
            toSection: .accounts
        )

        snapshot.appendItems(
            items,
            toSection: .accounts
        )
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func makeAccountGeneratedFromQueryItem(for query: String) -> ReceiverAccountSelectionListItem {
        let accountGeneratedFromQuery = Account(address: query)
        accountGeneratedFromQuery.authorization = .standard
        self.accountGeneratedFromQuery = accountGeneratedFromQuery

        let draft = IconWithShortAddressDraft(accountGeneratedFromQuery)
        let viewModel = AccountListItemViewModel(draft)

        let isPreviouslySelected = addressInputViewText == accountGeneratedFromQuery.address

        let item: ReceiverAccountSelectionListItem = .accountGeneratedFromQuery(
            viewModel: viewModel,
            isPreviouslySelected: isPreviouslySelected
        )

        return item
    }

    private func addAccountGeneratedFromQueryContent(
        item: ReceiverAccountSelectionListItem,
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendSections([ .accounts ])

        let headerItem = makeHeaderItem("title-account".localized)

        snapshot.appendItems(
            [ headerItem ],
            toSection: .accounts
        )

        snapshot.appendItems(
            [ item ],
            toSection: .accounts
        )
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func makeContactItems() -> [ReceiverAccountSelectionListItem] {
        return contacts.compactMap { contact in
            if let lastQuery {

                if isContactContainsNameOrAddress(
                    contact.value,
                    query: lastQuery
                ) {
                    return makeContactItem(contact.value)
                }

                return nil
            }

            return makeContactItem(contact.value)
        }
    }

    private func makeContactItem(_ contact: Contact) -> ReceiverAccountSelectionListItem {
        let imageSize = ReceiverAccountSelectionListContactCell.theme.imageSize

        let viewModel = ContactsViewModel(
            contact: contact,
            imageSize: CGSize(imageSize)
        )

        let isPreviouslySelected = addressInputViewText == contact.address

        let item: ReceiverAccountSelectionListItem = .contact(
            viewModel: viewModel,
            isPreviouslySelected: isPreviouslySelected
        )

        return item
    }

    private func addContactContent(
        items: [ReceiverAccountSelectionListItem],
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendSections([.contacts])

        let headerItem = makeHeaderItem("send-algos-contacts".localized)

        snapshot.appendItems(
            [ headerItem ],
            toSection: .contacts
        )

        snapshot.appendItems(
            items,
            toSection: .contacts
        )
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func makeNameServiceItems() -> [ReceiverAccountSelectionListItem] {
        return matchedAccounts.map(makeNameServiceItem)
    }

    private func makeNameServiceItem(_ nameService: NameService) -> ReceiverAccountSelectionListItem {
        let imageSource = DefaultURLImageSource(url: URL(string: nameService.service.logo))
        let nameServiceAccount = nameService.account.value
        let preview = NameServiceAccountListItem(
            address: nameServiceAccount.address,
            icon: imageSource,
            title: nameServiceAccount.address.shortAddressDisplay,
            subtitle: nameService.name
        )
        let viewModel = AccountListItemViewModel(preview)

        let isPreviouslySelected =
        addressInputViewText == nameServiceAccount.address ||
        addressInputViewText == nameService.name

        let item: ReceiverAccountSelectionListItem = .nameServiceAccount(
            viewModel: viewModel,
            isPreviouslySelected: isPreviouslySelected
        )

        return item
    }

    private func addNameServiceContent(
        items: [ReceiverAccountSelectionListItem],
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendSections([ .nameServiceAccounts ])

        let headerItem = makeHeaderItem("account-select-header-matched-accounts-title".localized)

        snapshot.appendItems(
            [ headerItem ],
            toSection: .nameServiceAccounts
        )

        snapshot.appendItems(
            items,
            toSection: .nameServiceAccounts
        )
    }

    private func addNameServiceSearchingContent(_ snapshot: inout Snapshot) {
        snapshot.appendSections([ .nameServiceAccounts ])

        let headerItem = makeHeaderItem("account-select-header-matched-accounts-title".localized)

        snapshot.appendItems(
            [ headerItem ],
            toSection: .nameServiceAccounts
        )

        snapshot.appendItems(
            [ .empty(.loading("1")) ],
            toSection: .nameServiceAccounts
        )
    }

    private func addNameServiceNoContent(_ snapshot: inout Snapshot) {
        snapshot.appendSections([ .nameServiceAccounts ])

        let headerItem = makeHeaderItem("account-select-header-matched-accounts-title".localized)

        snapshot.appendItems(
            [ headerItem ],
            toSection: .nameServiceAccounts
        )

        snapshot.appendItems(
            [ .empty(.noContent) ],
            toSection: .nameServiceAccounts
        )
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func makeHeaderItem(_ title: String) -> ReceiverAccountSelectionListItem {
        let viewModel = ReceiverAccountSelectionListHeaderViewModel(title)
        let headerItem: ReceiverAccountSelectionListItem = .header(viewModel)
        return headerItem
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func fetchNameServiceIfNeeded(for query: String?) {
        guard let preparedQuery = prepareQueryForValidation(query),
              isQueryValidNameService(preparedQuery) else {
            nameServiceAPIStatus = .idle
            return
        }

        fetchNameService(for: preparedQuery)
    }

    private func fetchNameService(for query: String?) {
        cancelOngoingNameServiceEndpoint()

        matchedAccounts = []

        nameServiceAPIStatus = .searching

        ongoingNameServiceEndpoint = api.fetchNameServices(NameServiceQuery(name: query)) {
            [weak self] result in
            guard let self = self else { return }

            self.nameServiceAPIStatus = .finished

            switch result {
            case .success(let nameServiceList):
                self.matchedAccounts = nameServiceList.results

                self.deliverContentSnapshot(for: query)
            case .failure:
                return
            }
        }
    }

    private func isQueryValidNameService(_ query: String?) -> Bool {
        let validationResult = nameServiceValidator.validate(query)
        return validationResult.isSuccess
    }

    private func prepareQueryForValidation(_ query: String?) -> String? {
        let preparedQuery = query?.trimmed().lowercased()
        return preparedQuery.unwrapNonEmptyString()
    }

    private func cancelOngoingNameServiceEndpoint() {
        ongoingNameServiceEndpoint?.cancel()
        ongoingNameServiceEndpoint = nil
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func deliverSnapshot(
        isLoading: Bool = false,
        _ snapshot: @escaping () -> Snapshot?
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            guard let snapshot = snapshot() else {
                return
            }

            self.publish(.didUpdate(snapshot, isLoading: isLoading))
        }
    }
}

extension ReceiverAccountSelectionListAPIDataController {
    private func publish(_ event: ReceiverAccountSelectionListDataControllerEvent) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
