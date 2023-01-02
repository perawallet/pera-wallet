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

//   SortAccountListLocalDataController.swift

import Foundation

final class SortAccountListLocalDataController: SortAccountListDataController {
    var eventHandler: ((SortAccountListDataControllerEvent) -> Void)?

    private(set) var selectedSortingAlgorithm: AccountSortingAlgorithm {
        didSet {
            if selectedSortingAlgorithm.id != oldValue.id {
                deliverContentSnapshot()
            }
        }
    }

    private var reorderedAccounts: [AccountHandle] = []
    private var reorderedAccountItems: [SortAccountListItem] = []

    private let sortingAlgorithms: [AccountSortingAlgorithm]

    private let session: Session
    private let sharedDataController: SharedDataController

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.sortAccounts.updates",
        qos: .userInitiated
    )

    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.session = session
        self.sharedDataController = sharedDataController
        self.sortingAlgorithms = sharedDataController.accountSortingAlgorithms
        self.selectedSortingAlgorithm =
            sharedDataController.selectedAccountSortingAlgorithm ?? AccountCustomReorderingAlgorithm()
    }
}

extension SortAccountListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension SortAccountListLocalDataController {
    func selectItem(
        at indexPath: IndexPath
    ) {
        guard let newSelectedSortingAlgorithm = sortingAlgorithms[safe: indexPath.item] else {
            return
        }

        selectedSortingAlgorithm = newSelectedSortingAlgorithm
    }

    func moveItem(
        from source: IndexPath,
        to destination: IndexPath
    ) {
        reorderedAccounts.move(
            from: source.item,
            to: destination.item
        )
        reorderedAccountItems.move(
            from: source.item,
            to: destination.item
        )
    }
}

extension SortAccountListLocalDataController {
    func performChanges() {
        saveSelectedSortingAlgorithm()

        if selectedSortingAlgorithm.isCustom {
            reorderedAccounts.enumerated().forEach {
                savePreferredOrder(
                    $0.offset,
                    of: $0.element.value
                )
            }
        }

        publish(.didComplete)
    }

    private func saveSelectedSortingAlgorithm() {
        sharedDataController.selectedAccountSortingAlgorithm = selectedSortingAlgorithm
    }

    private func savePreferredOrder(
        _ newOrder: Int,
        of account: Account
    ) {
        guard let authenticatedUser = session.authenticatedUser else {
            return
        }

        /// <note>
        /// Since the syncing is always running, the references of the cached accounts may change
        /// at this moment. Let's be sure we can switch to the new ordering immediately.
        let cachedAccount = sharedDataController.accountCollection[account.address]?.value
        cachedAccount?.preferredOrder = newOrder

        account.preferredOrder = newOrder

        authenticatedUser.updateLocalAccount(
            account,
            syncChangesImmediately: false
        )
        authenticatedUser.syncronize()
    }
}

extension SortAccountListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            self.addSortContent(&snapshot)

            if self.selectedSortingAlgorithm.isCustom {
                self.addOrderContent(&snapshot)
            }

            return snapshot
        }
    }

    private func addSortContent(
        _ snapshot: inout Snapshot
    ) {
        /// <todo>
        /// View model and selection should be separated.
        let items: [SortAccountListItem] = sortingAlgorithms.map {
            let isSelected = $0.id == selectedSortingAlgorithm.id
            let viewModel = SingleSelectionViewModel(
                title: $0.name,
                isSelected: isSelected
            )
            let value = SelectionValue(
                value: viewModel,
                isSelected: isSelected
            )
            return .sortOption(value)
        }
        
        snapshot.appendSections([.sortOptions])
        snapshot.appendItems(
            items,
            toSection: .sortOptions
        )
    }

    private func addOrderContent(
        _ snapshot: inout Snapshot
    ) {
        /// <note>
        /// Cache items once
        if reorderedAccounts.isEmpty {
            reorderedAccounts = sharedDataController.sortedAccounts()
            reorderedAccountItems = reorderedAccounts.map {
                let draft = AccountOrderingDraft(account: $0.value)
                let viewModel = AccountListItemViewModel(draft)
                return .reordering(viewModel)
            }
        }

        snapshot.appendSections([.reordering])
        snapshot.appendItems(
            reorderedAccountItems,
            toSection: .reordering
        )
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension SortAccountListLocalDataController {
    private func publish(
        _ event: SortAccountListDataControllerEvent
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

/// <todo>
/// Move it to `MacaroonUtils`
extension Array {
    mutating func move(
        from index: Index,
        to newIndex: Index
    ) {
        if index == newIndex {
            return
        }

        let movingElement = remove(at: index)
        insert(
            movingElement,
            at: newIndex
        )
    }
}
