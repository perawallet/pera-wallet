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

//   ExportAccountsConfirmationListLocalDataController.swift

import Foundation

final class ExportAccountsConfirmationListLocalDataController: ExportAccountsConfirmationListDataController {
    var eventHandler: ((ExportAccountsConfirmationListDataControllerEvent) -> Void)?

    private let snapshotQueue = DispatchQueue(label: "exportAccountsConfirmationListSnapshot")

    let selectedAccounts: [Account]

    init(
        selectedAccounts: [Account]
    ) {
        self.selectedAccounts = selectedAccounts
    }
}

extension ExportAccountsConfirmationListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension ExportAccountsConfirmationListLocalDataController {
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
        snapshot.appendSections([.accounts])

        addAccounts(
            &snapshot,
            accounts: selectedAccounts
        )
    }

    private func addAccounts(
        _ snapshot: inout Snapshot,
        accounts: [Account]
    ) {
        let accountItems: [ExportAccountsConfirmationListItemIdentifier] =
        accounts
            .map { account in
                let draft = IconWithShortAddressDraft(account)
                let viewModel = AccountPreviewViewModel(draft)

                let item =  ExportAccountsConfirmationListAccountCellItemIdentifier(
                    model: account,
                    viewModel: viewModel
                )
                return .account(.cell(item))
            }

        snapshot.appendItems(
            accountItems,
            toSection: .accounts
        )
    }
}

extension ExportAccountsConfirmationListLocalDataController {
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
        _ event: ExportAccountsConfirmationListDataControllerEvent
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
