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

//   ReceiveCollectibleAccountListAPIDataController.swift

import Foundation
import MacaroonUtils

final class ReceiveCollectibleAccountListAPIDataController:
    ReceiveCollectibleAccountListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((ReceiveCollectibleAccountListDataControllerEvent) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(
        label: "pera.receiveCollectibleAccount.updates",
        qos: .userInitiated
    )

    init(
        _ sharedDataController: SharedDataController
    ) {
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript(address: String?) -> AccountHandle? {
        return address.unwrap {
            sharedDataController.accountCollection[$0]
        }
    }
}

extension ReceiveCollectibleAccountListAPIDataController {
    func load() {
        sharedDataController.add(self)
    }
}

extension ReceiveCollectibleAccountListAPIDataController {
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

extension ReceiveCollectibleAccountListAPIDataController {
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
            var accountItems: [ReceiveCollectibleAccountListItem] = []

            let currency = self.sharedDataController.currency

            filteredAccounts
                .forEach {
                    let accountPortfolioItem = AccountPortfolioItem(
                        accountValue: $0,
                        currency: currency,
                        currencyFormatter: self.currencyFormatter
                    )
                    let accountListItemViewModel = AccountListItemViewModel(accountPortfolioItem)
                    let cellItem: ReceiveCollectibleAccountListItem = .account(
                        accountListItemViewModel
                    )

                    accounts.append($0)
                    accountItems.append(cellItem)
                }

            var snapshot = Snapshot()

            snapshot.appendSections([.info, .header, .accounts])

            if !accounts.isEmpty {
                snapshot.appendItems(
                    [.info],
                    toSection: .info
                )
                
                let headerItem: ReceiveCollectibleAccountListItem = .header(
                    ReceiveCollectibleAccountListHeaderViewModel()
                )

                snapshot.appendItems(
                    [headerItem],
                    toSection: .header
                )

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
}

extension ReceiveCollectibleAccountListAPIDataController {
    private func publish(
        _ event: ReceiveCollectibleAccountListDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
