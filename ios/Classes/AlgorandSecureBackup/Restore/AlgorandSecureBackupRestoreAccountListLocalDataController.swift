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

//   AlgorandSecureBackupRestoreAccountListLocalDataController.swift

import Foundation
import OrderedCollections

final class AlgorandSecureBackupRestoreAccountListLocalDataController:
    AlgorandSecureBackupAccountListDataController {
    var eventHandler: ((AlgorandSecureBackupAccountListDataControllerEvent) -> Void)?

    private(set) var accountsHeaderViewModel: AlgorandSecureBackupAccountListAccountsHeaderViewModel!

    private lazy var accounts: OrderedDictionary<Index, Account> = [:]
    private lazy var selectedAccounts: OrderedDictionary<Index, Account> = [:]

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.algorandSecureBackupRestoreAccountList.updates",
        qos: .userInitiated
    )

    private let accountImportParameters: [AccountImportParameters]

    init(accountImportParameters: [AccountImportParameters]) {
        self.accountImportParameters = accountImportParameters
    }
}

extension AlgorandSecureBackupRestoreAccountListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension AlgorandSecureBackupRestoreAccountListLocalDataController {
    func isAccountSelected(at index: Index) -> Bool {
        return selectedAccounts[index] != nil
    }

    var isContinueActionEnabled: Bool {
        return !selectedAccounts.isEmpty
    }

    var hasSingleAccount: Bool {
        return accounts.isSingular
    }

    func getSelectedAccounts() -> [Account] {
        return selectedAccounts.values.elements
    }
}

extension AlgorandSecureBackupRestoreAccountListLocalDataController {
    func getAccountsHeaderItemState() -> AlgorandSecureBackupAccountListAccountHeaderItemState {
        if selectedAccounts.isEmpty {
            return .selectAll
        }

        if accounts.values.count == selectedAccounts.values.count {
            return .unselectAll
        }

        return .partialSelection
    }
}

extension AlgorandSecureBackupRestoreAccountListLocalDataController {
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

extension AlgorandSecureBackupRestoreAccountListLocalDataController {
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
        let algorandSDK = AlgorandSDK()
        let filteredAccounts = accountImportParameters.filter { $0.isImportable(using: algorandSDK) }

        if filteredAccounts.isEmpty {
            addEmptySection(&snapshot)
            return
        }

        let restoredAccounts = filteredAccounts.map { accountParameter in
            let accountAddress = accountParameter.address

            let accountInformation = AccountInformation(
                address: accountAddress,
                name: accountParameter.name ?? accountAddress.shortAddressDisplay,
                isWatchAccount: false, 
                isBackedUp: true
            )

            return Account(localAccount: accountInformation)
        }
        let accounts: [Account] =
            restoredAccounts
                .filter {
                    let isWatchAccount = $0.isWatchAccount
                    let isRekeyedToAnyAccount = $0.hasAuthAccount()
                    return !isWatchAccount && !isRekeyedToAnyAccount
                }

        addAccountItems(&snapshot, accounts: accounts)
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
        let viewModel = AlgorandSecureBackupAccountListAccountsHeaderViewModel(accountsCount: accounts.count)

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
        let accountItems: [AlgorandSecureBackupAccountListItemIdentifier] =
        accounts
            .enumerated()
            .map {
                let account = $0.element
                let draft = IconWithShortAddressDraft(account)
                let viewModel = AccountListItemViewModel(draft)

                let item = AlgorandSecureBackupAccountListAccountCellItemIdentifier(
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

    private func addEmptySection(
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendItems(
            [ .noContent ],
            toSection: .empty
        )
    }
}

extension AlgorandSecureBackupRestoreAccountListLocalDataController {
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
        _ event: AlgorandSecureBackupAccountListDataControllerEvent
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
