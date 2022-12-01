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

//   SendCollectibleAccountListAPIDataController.swift

import Foundation
import MacaroonUtils
import CoreGraphics

final class SendCollectibleAccountListAPIDataController:
    SendCollectibleAccountListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((SendCollectibleAccountListDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(
        label: "com.algorand.queue.receiveCollectibleAccountListAPIDataController"
    )

    private var accounts: [AccountHandle] = []

    typealias Address = String
    private var contacts: [Address: Contact] = [:]

    private var accountGeneratedFromQuery: Account?

    private var lastQuery: String?

    private let addressInputViewText: String?

    init(
        _ sharedDataController: SharedDataController,
        addressInputViewText: String?
    ) {
        self.sharedDataController = sharedDataController
        self.addressInputViewText = addressInputViewText
        self.accounts = sharedDataController.sortedAccounts()
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript(accountAddress address: Address) -> Account? {
        return (sharedDataController.accountCollection[address]?.value) ?? accountGeneratedFromQuery
    }

    subscript(contactAddress address: Address) -> Contact? {
        return contacts[address]
    }
}

extension SendCollectibleAccountListAPIDataController {
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

extension SendCollectibleAccountListAPIDataController {
    func load() {
        sharedDataController.add(self)

        getContacts { contacts in
            self.contacts =
            contacts.reduce(
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
        accountGeneratedFromQuery = nil

        deliverContentSnapshot(for: query)
    }

    func resetSearch() {
        lastQuery = nil
        accountGeneratedFromQuery = nil
        deliverContentSnapshot()
    }
}

extension SendCollectibleAccountListAPIDataController {
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

            let updatedAccounts = sharedDataController.sortedAccounts()
            accounts = updatedAccounts
            deliverContentSnapshot(for: lastQuery)
        }
    }
}

extension SendCollectibleAccountListAPIDataController {
    private func deliverInitialSnapshot() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingSnapshot()
        } else {
            deliverNoContentSnapshot()
        }
    }

    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [.empty(.loading("1")), .empty(.loading("2"))],
                toSection: .loading
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot(
        for query: String? = nil
    ) {
        lastQuery = query

        var contactItems: [SendCollectibleAccountListItem] = []

        contacts
            .filter { contact in
                if let query = query {
                    return isContactContainsNameOrAddress(
                        contact.value,
                        query: query
                    )
                }

                return true
            }
            .forEach { contact in
                let imageSize = SendCollectibleContactCell.theme.imageSize

                let cellItem: SendCollectibleAccountListItem = .contact(
                    viewModel: ContactsViewModel(
                        contact: contact.value,
                        imageSize: CGSize(imageSize)
                    ),
                    isPreviouslySelected: addressInputViewText == contact.value.address
                )

                contactItems.append(cellItem)
            }

        var accountItems: [SendCollectibleAccountListItem] = []

        accounts
            .filter {
                if let query = query {
                    return isAccountContainsNameOrAddress($0, query: query)
                }

                return true
            }
            .forEach { account in
                let cellItem: SendCollectibleAccountListItem = .account(
                    viewModel: AccountListItemViewModel(
                        IconWithShortAddressDraft(
                            account.value
                        )
                    ),
                    isPreviouslySelected: addressInputViewText == account.value.address
                )

                accountItems.append(cellItem)
            }

        if accountItems.isEmpty
            && contactItems.isEmpty {

            if let query = query,
               query.isValidatedAddress {
                deliverAccountSnapshot(for: query)
                return
            }

            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot {
            var snapshot = Snapshot()

            if !contactItems.isEmpty {
                snapshot.appendSections([.contacts])

                let contactsHeaderItem: SendCollectibleAccountListItem = .header(
                    SendCollectibleAccountListHeaderViewModel(
                        "send-algos-contacts".localized
                    )
                )

                snapshot.appendItems(
                    [contactsHeaderItem],
                    toSection: .contacts
                )

                snapshot.appendItems(
                    contactItems,
                    toSection: .contacts
                )
            }

            if !accountItems.isEmpty {
                snapshot.appendSections([.accounts])

                let accountsHeaderItem: SendCollectibleAccountListItem = .header(
                    SendCollectibleAccountListHeaderViewModel(
                        "account-select-header-accounts-title".localized
                    )
                )

                snapshot.appendItems(
                    [accountsHeaderItem],
                    toSection: .accounts
                )

                snapshot.appendItems(
                    accountItems,
                    toSection: .accounts
                )
            }
            return snapshot
        }
    }

    private func deliverAccountSnapshot(
        for query: String
    ) {
        let accountsHeaderItem: SendCollectibleAccountListItem = .header(
            SendCollectibleAccountListHeaderViewModel(
                "title-account".localized
            )
        )

        let accountGeneratedFromQuery = Account(address: query, type: .standard)
        self.accountGeneratedFromQuery = accountGeneratedFromQuery
        let cellItem: SendCollectibleAccountListItem = .account(
            viewModel: AccountListItemViewModel(
                IconWithShortAddressDraft(
                    accountGeneratedFromQuery
                )
            ),
            isPreviouslySelected: addressInputViewText == accountGeneratedFromQuery.address
        )

        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.accounts])

            snapshot.appendItems(
                [accountsHeaderItem],
                toSection: .accounts
            )

            snapshot.appendItems(
                [cellItem],
                toSection: .accounts
            )

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent)],
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

    private func isContactContainsNameOrAddress(_ contact: Contact, query: String) -> Bool {
        return contact.name.someString.localizedCaseInsensitiveContains(query)  ||
        contact.address.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAccountContainsNameOrAddress(_ account: AccountHandle, query: String) -> Bool {
        return account.value.name.someString.localizedCaseInsensitiveContains(query) ||
        account.value.address.localizedCaseInsensitiveContains(query)
    }
}

extension SendCollectibleAccountListAPIDataController {
    private func publish(
        _ event:SendCollectibleAccountListDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
