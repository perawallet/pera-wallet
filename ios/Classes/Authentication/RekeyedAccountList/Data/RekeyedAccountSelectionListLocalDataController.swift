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

//   RekeyedAccountSelectionListLocalDataController.swift

import Foundation
import OrderedCollections

final class RekeyedAccountSelectionListLocalDataController: RekeyedAccountSelectionListDataController {
    var eventHandler: ((RekeyedAccountSelectionListDataControllerEvent) -> Void)?

    let authAccount: Account

    private lazy var accounts: OrderedDictionary<Index, Account> = [:]
    private lazy var selectedAccounts: OrderedDictionary<Index, Account> = [:]

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.rekeyedAccountSelectionListLocalDataController.updates",
        qos: .userInitiated
    )

    private let sharedDataController: SharedDataController
    private let rekeyedAccounts: [Account]

    init(
        authAccount: Account,
        rekeyedAccounts: [Account],
        sharedDataController: SharedDataController
    ) {
        self.authAccount = authAccount
        self.rekeyedAccounts = rekeyedAccounts
        self.sharedDataController = sharedDataController
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    func load() {
        deliverSnapshotForAccountLoading()
        deliverSnapshotForContent()
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    func isAccountSelected(at index: Index) -> Bool {
        return selectedAccounts[index] != nil
    }

    var isPrimaryActionEnabled: Bool {
        return !selectedAccounts.isEmpty
    }

    var hasSingleAccount: Bool {
        return accounts.isSingular
    }

    func getAccounts() -> [Account] {
        return rekeyedAccounts
    }

    func getSelectedAccounts() -> [Account] {
        return selectedAccounts.values.elements
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    func selectAccountItem(at index: Index) {
        guard let selectedAccount = accounts[index] else {
            return
        }

        selectedAccounts[index] = selectedAccount
    }

    func unselectAccountItem(at index: Index) {
        selectedAccounts[index] = nil
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    private func deliverSnapshotForAccountLoading() {
        deliverSnapshot {
            [weak self] in
            guard let self else { return nil }

            var snapshot = Snapshot()
            self.appendSectionsForAccountLoading(into: &snapshot)
            return snapshot
        }
    }

    private func appendSectionsForAccountLoading(into snapshot: inout Snapshot) {
        let items = makeAccountLoadingItems()
        snapshot.appendSections([ .accounts ])
        snapshot.appendItems(
            items,
            toSection: .accounts
        )
    }

    private func deliverSnapshotForContent() {
        deliverSnapshot {
            [weak self] in
            guard let self else { return nil }

            var snapshot = Snapshot()
            self.appendSectionsForContent(into: &snapshot)
            return snapshot
        }
    }

    private func appendSectionsForContent(into snapshot: inout Snapshot) {
        let items = makeAccountItems()
        snapshot.appendSections([ .accounts ])
        snapshot.appendItems(
            items,
            toSection: .accounts
        )
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    private func makeAccountLoadingItems() -> [RekeyedAccountSelectionListItemIdentifier] {
        return [ .accountLoading ]
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    private func makeAccountItems() -> [RekeyedAccountSelectionListItemIdentifier] {
        let items =
            rekeyedAccounts
                .enumerated()
                .map {
                    let account = $0.element

                    self.accounts[$0.offset] = account

                    return makeAccountItem(account)
                }
        return items
    }

    private func makeAccountItem(_ account: Account) -> RekeyedAccountSelectionListItemIdentifier {
        let viewModel = LedgerAccountViewModel(account)
        let item = RekeyedAccountSelectionListAccountCellItemIdentifier(
            model: account,
            viewModel: viewModel
        )
        return .account(item)
    }
}

extension RekeyedAccountSelectionListLocalDataController {
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

    private func publish(_ event: RekeyedAccountSelectionListDataControllerEvent) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }

            self.eventHandler?(event)
        }
    }
}
