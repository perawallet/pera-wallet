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

//
//   SelectAccountAPIDataController.swift

import Foundation
import MacaroonUtils

final class SelectAccountAPIDataController:
    SelectAccountDataController,
    SharedDataControllerObserver {
    var eventHandler: ((SelectAccountDataControllerEvent) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.selectAccount.updates",
        qos: .userInitiated
    )
    private let transactionAction: TransactionAction

    var shouldFilterAccount: ((Account) -> Bool)?

    init(
        _ sharedDataController: SharedDataController,
        transactionAction: TransactionAction
    ) {
        self.sharedDataController = sharedDataController
        self.transactionAction = transactionAction
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension SelectAccountAPIDataController {
    func load() {
        sharedDataController.add(self)
    }
}

extension SelectAccountAPIDataController {
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
            deliverContentSnapshot()
        }
    }
}

extension SelectAccountAPIDataController {
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
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.loading("1")), .empty(.loading("2"))],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        let filterAlgorithm = AuthorizedAccountListFilterAlgorithm()
        let filteredAccounts = sharedDataController.sortedAccounts().filter(filterAlgorithm.getFormula)

        if filteredAccounts.isEmpty {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var accounts: [AccountHandle] = []
            var accountItems: [SelectAccountListViewItem] = []

            let currency = self.sharedDataController.currency
            let currencyFormatter = self.currencyFormatter

            self.sharedDataController.sortedAccounts().forEach { accountHandle in
                let isAuthorizedAccount = accountHandle.value.authorization.isAuthorized
                if !isAuthorizedAccount {
                    return
                }

                if let shouldFilterAccount = self.shouldFilterAccount,
                   shouldFilterAccount(accountHandle.value) {
                    return
                }

                let item = AccountPortfolioItem(
                    accountValue: accountHandle,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let viewModel = AccountListItemViewModel(item)
                let listItem = SelectAccountListViewItem.account(viewModel, accountHandle)

                accounts.append(accountHandle)
                accountItems.append(listItem)
            }

            var snapshot = Snapshot()
            
            if accounts.isEmpty {
                self.appendSectionsForNoContent(into: &snapshot)
            } else {
                snapshot.appendSections([.accounts])
                snapshot.appendItems(
                    accountItems,
                    toSection: .accounts
                )
            }

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()
            self.appendSectionsForNoContent(into: &snapshot)
            return snapshot
        }
    }

    private func appendSectionsForNoContent(
        into snapshot: inout Snapshot
    ) {
        let items = makeNoContentItems()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            items,
            toSection: .empty
        )
    }

    private func makeNoContentItems() -> [SelectAccountListViewItem] {
        let viewModel = SelectAccountNoContentViewModel()
        return [ .empty(.noContent(viewModel)) ]
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

extension SelectAccountAPIDataController {
    private func publish(
        _ event: SelectAccountDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
