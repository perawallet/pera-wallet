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

//   BidaliAccountSelectionListLocalDataController.swift

import Foundation
import MacaroonUtils

protocol BidaliAccountSelectionListItemDataSource: AnyObject {
    var noContentItem: NoContentViewModel { get }
    var headerItem: BidaliAccountSelectionListHeaderViewModel { get }

    typealias AccountAddress = String
    var accountItems: [AccountAddress: AccountListItemViewModel] { get }
}

final class BidaliAccountSelectionListLocalDataController:
    AccountSelectionListDataController,
    BidaliAccountSelectionListItemDataSource {
    typealias SectionIdentifierType = BidaliAccountSelectionListSectionIdentifier
    typealias ItemIdentifierType = BidaliAccountSelectionListItemIdentifier

    var eventHandler: ((Event) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()

    private let snapshotQueue = DispatchQueue(label: "bidaliAccountSelectionListLocalDataController")

    private var accounts: [AccountHandle] = []

    private(set) var noContentItem: NoContentViewModel = AccountSelectionListNoContentViewModel()
    private(set) var headerItem = BidaliAccountSelectionListHeaderViewModel()
    private(set) var accountItems: [AccountAddress: AccountListItemViewModel] = [:]

    private let sharedDataController: SharedDataController

    private var lastSnapshot: Snapshot?

    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
    }

    subscript(indexPath: IndexPath) -> AccountHandle? {
        let accountsSection = lastSnapshot?.indexOfSection(.accounts)

        guard indexPath.section == accountsSection else {
            return nil
        }

        return accounts[safe: indexPath.row]
    }
}

extension BidaliAccountSelectionListLocalDataController {
    func load() {
        asyncBackground(qos: .userInitiated) {
            [weak self] in
            guard let self = self else { return }

            self.deliverLoadingSnapshot()

            let sortedAccounts = self.sharedDataController.sortedAccounts()

            let filterAlgorithm = AuthorizedAccountListFilterAlgorithm()
            let filteredAccounts = sortedAccounts.filter(filterAlgorithm.getFormula)

            self.accounts = filteredAccounts

            if filteredAccounts.isEmpty {
                self.deliverNoContentSnapshot()
            } else {
                self.deliverContentSnapshot(filteredAccounts)
            }
        }
    }
}

extension BidaliAccountSelectionListLocalDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])

            let items: [BidaliAccountSelectionListItemIdentifier] = [
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

    private func makeAccountItem(_ account: AccountHandle) -> BidaliAccountSelectionListItemIdentifier {
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

        let itemIdentifier = BidaliAccountSelectionListAccountItemIdentifier(aRawAccount)
        return .account(itemIdentifier)
    }
}

extension BidaliAccountSelectionListLocalDataController {
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

enum BidaliAccountSelectionListSectionIdentifier: Hashable {
    case empty
    case loading
    case accounts
}

enum BidaliAccountSelectionListItemIdentifier: Hashable {
    case empty(BidaliAccountSelectionListEmptyItemIdentifier)
    case loading(BidaliAccountSelectionListLoadingItemIdentifier)
    case account(BidaliAccountSelectionListAccountItemIdentifier)
}

enum BidaliAccountSelectionListEmptyItemIdentifier: Hashable {
    case noContent
}

enum BidaliAccountSelectionListLoadingItemIdentifier: Hashable {
    case account(UUID)
}

struct BidaliAccountSelectionListAccountItemIdentifier: Hashable {
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
