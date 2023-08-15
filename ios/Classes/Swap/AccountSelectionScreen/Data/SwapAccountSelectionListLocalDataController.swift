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

//   SwapAccountSelectionListLocalDataController.swift

import Foundation
import MacaroonUtils

protocol SwapAccountSelectionListItemDataSource: AnyObject {
    var noContentItem: NoContentViewModel { get }
    var headerItem: SwapAccountSelectionListHeaderViewModel { get }

    typealias AccountAddress = String
    var accountItems: [AccountAddress: AccountListItemViewModel] { get }
}

final class SwapAccountSelectionListLocalDataController:
    AccountSelectionListDataController,
    SwapAccountSelectionListItemDataSource {
    typealias SectionIdentifierType = SwapAccountSelectionListSectionIdentifier
    typealias ItemIdentifierType = SwapAccountSelectionListItemIdentifier

    var eventHandler: ((Event) -> Void)?

    private let snapshotQueue = DispatchQueue(label: "swapAccountSelectionListLocalDataController")

    private var accounts: [AccountHandle] = []

    private(set) var noContentItem: NoContentViewModel = AccountSelectionListNoContentViewModel()
    private(set) var headerItem = SwapAccountSelectionListHeaderViewModel()
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

extension SwapAccountSelectionListLocalDataController {
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

extension SwapAccountSelectionListLocalDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])

            let items: [SwapAccountSelectionListItemIdentifier] = [
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
        let accountItems: [SwapAccountSelectionListItemIdentifier] =
        accounts
            .map { accountHandle in
                let account = accountHandle.value
                let draft = IconWithShortAddressDraft(account)
                let viewModel = AccountListItemViewModel(draft)

                self.accountItems[account.address] = viewModel

                return .account(SwapAccountSelectionListAccountItemIdentifier(account))
            }

        snapshot.appendItems(
            accountItems,
            toSection: .accounts
        )
    }
}

extension SwapAccountSelectionListLocalDataController {
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

enum SwapAccountSelectionListSectionIdentifier: Hashable {
    case empty
    case loading
    case accounts
}

enum SwapAccountSelectionListItemIdentifier: Hashable {
    case empty(SwapAccountSelectionListEmptyItemIdentifier)
    case loading(SwapAccountSelectionListLoadingItemIdentifier)
    case account(SwapAccountSelectionListAccountItemIdentifier)
}

enum SwapAccountSelectionListEmptyItemIdentifier: Hashable {
    case noContent
}

enum SwapAccountSelectionListLoadingItemIdentifier: Hashable {
    case account(UUID)
}

struct SwapAccountSelectionListAccountItemIdentifier: Hashable {
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
