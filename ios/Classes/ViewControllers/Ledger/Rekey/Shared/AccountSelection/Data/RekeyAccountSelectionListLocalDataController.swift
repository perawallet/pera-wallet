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

//   RekeyAccountSelectionListLocalDataController.swift

import Foundation
import MacaroonUtils

protocol RekeyAccountSelectionListItemDataSource: AnyObject {
    var noContentItem: NoContentViewModel { get }
    var headerItem: RekeyAccountSelectionListHeaderViewModel { get }

    typealias AccountAddress = String
    var accountItems: [AccountAddress: AccountListItemViewModel] { get }
}

final class RekeyAccountSelectionListLocalDataController:
    AccountSelectionListDataController,
    RekeyAccountSelectionListItemDataSource {
    typealias SectionIdentifierType = RekeyAccountSelectionListSectionIdentifier
    typealias ItemIdentifierType = RekeyAccountSelectionListItemIdentifier

    var eventHandler: ((Event) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var rekeyingValidator = RekeyingValidator(
        session: session,
        sharedDataController: sharedDataController
    )

    private let snapshotQueue = DispatchQueue(label: "rekeyAccountSelectionListLocalDataController")

    private var accounts: [AccountHandle] = []

    private(set) var noContentItem: NoContentViewModel = AccountSelectionListNoContentViewModel()
    private(set) var headerItem = RekeyAccountSelectionListHeaderViewModel()
    private(set) var accountItems: [AccountAddress: AccountListItemViewModel] = [:]

    private let sharedDataController: SharedDataController
    private let session: Session
    private let account: Account

    private var lastSnapshot: Snapshot?

    init(
        sharedDataController: SharedDataController,
        session: Session,
        account: Account
    ) {
        self.sharedDataController = sharedDataController
        self.session = session
        self.account = account
    }

    subscript(indexPath: IndexPath) -> AccountHandle? {
        let accountsSection = lastSnapshot?.indexOfSection(.accounts)

        guard indexPath.section == accountsSection else {
            return nil
        }

        return accounts[safe: indexPath.row]
    }
}

extension RekeyAccountSelectionListLocalDataController {
    func load() {
        asyncBackground(qos: .userInitiated) {
            [weak self] in
            guard let self = self else { return }

            self.deliverLoadingSnapshot()

            let sortedAccounts = self.sharedDataController.sortedAccounts()

            let filteredAccounts = sortedAccounts.filter {
                let rawAccount = $0.value

                if !rawAccount.authorization.isAuthorized {
                    return false
                }

                /// <note>
                /// We're not displaying the same account in this list, we've a different flow for undoing the rekey.
                if rawAccount.isSameAccount(with: self.account) {
                    return false
                }

                let isRekeyingRestricted = self.isRekeyingRestricted(to: rawAccount)
                return !isRekeyingRestricted
            }
            self.accounts = filteredAccounts

            if filteredAccounts.isEmpty {
                self.deliverNoContentSnapshot()
            } else {
                self.deliverContentSnapshot(filteredAccounts)
            }
        }
    }
}

extension RekeyAccountSelectionListLocalDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])

            let items: [RekeyAccountSelectionListItemIdentifier] = [
                .loading(.account(UUID())),
                .loading(.account(UUID())),
                .loading(.account(UUID()))
            ]

            snapshot.appendItems(
                items,
                toSection: .loading
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

    private func deliverContentSnapshot(_ accounts: [AccountHandle]) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return nil }
            var snapshot = Snapshot()

            self.addAccountsSection(
                &snapshot,
                accounts: accounts
            )

            return snapshot
        }
    }

    private func addAccountsSection(
        _ snapshot: inout Snapshot,
        accounts: [AccountHandle]
    ) {
        snapshot.appendSections([.accounts])

        addAccounts(
            &snapshot,
            accounts: accounts
        )
    }

    private func addAccounts(
        _ snapshot: inout Snapshot,
        accounts: [AccountHandle]
    ) {
        let items = accounts.map(makeAccountItem)

        snapshot.appendItems(
            items,
            toSection: .accounts
        )
    }

    private func makeAccountItem(_ account: AccountHandle) -> RekeyAccountSelectionListItemIdentifier {
        let currency = sharedDataController.currency
        let currencyFormatter = currencyFormatter
        let item = AccountPortfolioItem(
            accountValue: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )

        let aRawAccount = account.value
        let viewModel = AccountListItemViewModel(item)

        self.accountItems[aRawAccount.address] = viewModel

        let itemIdentifier = RekeyAccountSelectionListAccountItemIdentifier(aRawAccount)
        return .account(itemIdentifier)
    }
}

extension RekeyAccountSelectionListLocalDataController {
    private func deliverSnapshot(_ snapshot: @escaping () -> Snapshot?) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            guard let snapshot = snapshot() else {
                return
            }

            self.publish(.didUpdate(snapshot))
        }
    }

    private func publish(_ event: Event) {
        asyncMain {
            [weak self] in
            guard let self = self else {
                return
            }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

enum RekeyAccountSelectionListSectionIdentifier: Hashable {
    case empty
    case loading
    case accounts
}

enum RekeyAccountSelectionListItemIdentifier: Hashable {
    case empty(RekeyAccountSelectionListEmptyItemIdentifier)
    case loading(RekeyAccountSelectionListLoadingItemIdentifier)
    case account(RekeyAccountSelectionListAccountItemIdentifier)
}

enum RekeyAccountSelectionListEmptyItemIdentifier: Hashable {
    case noContent
}

enum RekeyAccountSelectionListLoadingItemIdentifier: Hashable {
    case account(UUID)
}

struct RekeyAccountSelectionListAccountItemIdentifier: Hashable {
    private(set) var accountAddress: String

    init(_ account: Account) {
        accountAddress = account.address
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(accountAddress)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.accountAddress == rhs.accountAddress
    }
}

extension RekeyAccountSelectionListLocalDataController {
    private func isRekeyingRestricted(to account: Account) -> Bool {
        let validation = rekeyingValidator.validateRekeying(
            from: self.account,
            to: account
        )

        /// <note>
        /// Rekeying a standard account to ledger account should not be handled from this flow.
        /// So, the ledger accounts are filtered separately.
        return validation.isFailure || account.authorization.isLedger
    }
}
