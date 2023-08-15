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

//   ExportAccountListLocalDataController.swift

import Foundation
import OrderedCollections

final class ExportAccountListLocalDataController: ExportAccountListDataController {
    var eventHandler: ((ExportAccountListDataControllerEvent) -> Void)?

    private(set) var accountsHeaderViewModel: ExportAccountListAccountsHeaderViewModel!

    private lazy var accounts: OrderedDictionary<Index, Account> = [:]
    private lazy var selectedAccounts: OrderedDictionary<Index, Account> = [:]

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.exportAccounts.updates",
        qos: .userInitiated
    )

    private let sharedDataController: SharedDataController
    
    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
    }
}

extension ExportAccountListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension ExportAccountListLocalDataController {
    func isAccountSelected(at index: Index) -> Bool {
        return selectedAccounts[index] != nil
    }

    var isContinueActionEnabled: Bool {
        return !selectedAccounts.isEmpty
    }

    var hasAccounts: Bool {
        return !accounts.isEmpty
    }

    var hasSingleAccount: Bool {
        return accounts.isSingular
    }

    func getSelectedAccounts() -> [Account] {
        return selectedAccounts.values.elements
    }
}

extension ExportAccountListLocalDataController {
    func getAccountsHeaderItemState() -> ExportAccountListAccountHeaderItemState {
        if selectedAccounts.isEmpty {
            return .selectAll
        }

        if accounts.values.count == selectedAccounts.values.count {
            return .unselectAll
        }

        return .partialSelection
    }
}

extension ExportAccountListLocalDataController {
    func selectAccountItem(at index: Index) {
        guard let selectedAccount = accounts[index] else {
            return
        }

        selectedAccounts[index] = selectedAccount
    }

    func unselectAccountItem(at index: Index ) {
        selectedAccounts[index] = nil
    }

    func selectAllAccountsItems() {
        selectedAccounts = accounts
    }

    func unselectAllAccountsItems() {
        selectedAccounts = [:]
    }
}

extension ExportAccountListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = Snapshot()

            self.addAccountsSection(
                &snapshot
            )

            return snapshot
        }
    }

    private func addAccountsSection(
        _ snapshot: inout Snapshot
    ) {
        let accounts: [Account] =
            sharedDataController
                .sortedAccounts()
                .filter {
                    let isWatchAccount = $0.value.authorization.isWatch
                    let requiresLedgerConnection = $0.value.requiresLedgerConnection()
                    return !isWatchAccount && !requiresLedgerConnection
                }.map {
                    $0.value
                }

        if accounts.isEmpty {
            addNoContent(&snapshot)
        } else {
            addAccountItems(&snapshot, accounts: accounts)
        }
    }

    private func addAccountItems(
        _ snapshot: inout Snapshot,
        accounts: [Account]
    ) {
        snapshot.appendSections([.accounts])

        addAccountsHeader(
            &snapshot,
            accounts: accounts
        )
        addAccounts(
            &snapshot,
            accounts: accounts
        )
    }

    private func addAccountsHeader(
        _ snapshot: inout Snapshot,
        accounts: [Account]
    ) {
        let viewModel = ExportAccountListAccountsHeaderViewModel(accountsCount: accounts.count)

        accountsHeaderViewModel = viewModel

        snapshot.appendItems(
            [ .account(.header(accountsHeaderViewModel)) ],
            toSection: .accounts
        )
    }

    private func addAccounts(
        _ snapshot: inout Snapshot,
        accounts: [Account]
    ) {
        let accountItems: [ExportAccountListItemIdentifier] =
        accounts
            .enumerated()
            .map {
                let account = $0.element
                let draft = IconWithShortAddressDraft(account)
                let viewModel = AccountListItemViewModel(draft)

                let item = ExportAccountListAccountCellItemIdentifier(
                    model: account,
                    viewModel: viewModel
                )

                self.accounts[$0.offset] = account

                return .account(.cell(item))
            }

        snapshot.appendItems(
            accountItems,
            toSection: .accounts
        )
    }

    private func addNoContent(
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendSections([.empty])
        snapshot.appendItems([.noContent], toSection: .empty)
    }
}

extension ExportAccountListLocalDataController {
    private func deliverSnapshot(
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

            self.publish(.didUpdate(snapshot))
        }
    }

    private func publish(
        _ event: ExportAccountListDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
