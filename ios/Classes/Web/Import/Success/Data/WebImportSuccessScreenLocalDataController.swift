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

//   WebImportSuccessScreenLocalDataController.swift

import Foundation
import MacaroonUtils

class WebImportSuccessScreenLocalDataController:
    WebImportSuccessScreenDataController {

    var eventHandler: ((WebImportSuccessScreenDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.web.import.successScreen.updates",
        qos: .userInitiated
    )

    private var accountModelsCache: [String: Account] = [:]
    private var accountViewModelsCache: [String: AccountListItemViewModel] = [:]

    private let result: ImportAccountScreen.Result

    subscript(address: String) -> Account? {
        findModel(for: address)
    }

    subscript(address: String) -> AccountListItemViewModel? {
        findViewModel(for: address)
    }

    init(result: ImportAccountScreen.Result) {
        self.result = result
    }

    func createHeaderItem(importedAccountCount: Int) -> [WebImportSuccessListViewItem]{
        return [.header(.init(importedAccountCount: importedAccountCount))]
    }

    func createMissingAccountItem(
        unimportedAccountCount: Int,
        unsupportedAccountCount: Int
    ) -> [WebImportSuccessListViewItem] {
        return [
            .missingAccounts(
                .init(
                    unimportedAccountCount: unimportedAccountCount,
                    unsupportedAccountCount: unsupportedAccountCount
                )
            )
        ]
    }

}

extension WebImportSuccessScreenLocalDataController {
    func load() {
        clearCache()
        deliverContentSnapshot()
    }

    private func findModel(for address: String) -> Account? {
        return accountModelsCache[address]
    }

    private func findViewModel(for address: String) -> AccountListItemViewModel? {
        if let cachedViewModel = accountViewModelsCache[address] {
            return cachedViewModel
        } else {
            let account = findModel(for: address)
            return account.unwrap(AccountListItemViewModel.init)
        }
    }
}

extension WebImportSuccessScreenLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }
            var snapshot = Snapshot()

            snapshot.appendSections([.accounts])

            let importedAccounts = self.result.importedAccounts
            let importedAccountCount = importedAccounts.count
            let unimportedAccountCount = self.result.unimportedAccounts.count
            let algorandSDK = AlgorandSDK()
            let unsupportedAccountCount = self.result.parameters.filter {
                !$0.isImportable(using: algorandSDK)
            }.count

            snapshot.appendItems(self.createHeaderItem(importedAccountCount: importedAccountCount))

            if unimportedAccountCount > 0 || unsupportedAccountCount > 0 {
                snapshot.appendItems(
                    self.createMissingAccountItem(
                        unimportedAccountCount: unimportedAccountCount,
                        unsupportedAccountCount: unsupportedAccountCount
                    )
                )
            }

            snapshot.appendItems(self.createAccountListItems(accounts: importedAccounts))

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

    private func createAccountListItems(
        accounts: [Account]
    ) -> [WebImportSuccessListViewItem] {
        var listItems: [WebImportSuccessListViewItem] = []
        accounts.forEach { account in
            let item = createAccountListItem(
                account: account
            )
            listItems.append(item)
        }
        return listItems
    }

    private func createAccountListItem(
        account: Account
    ) -> WebImportSuccessListViewItem {
        saveToCache(account)

        let accountItem = WebImportSuccessListViewAccountItem(accountAddress: account.address)
        return .account(accountItem)
    }

    private func saveToCache(_ account: Account) {
        accountModelsCache[account.address] = account
        accountViewModelsCache[account.address] = AccountListItemViewModel(account)
    }

    private func clearCache() {
        accountModelsCache = [:]
        accountViewModelsCache = [:]
    }
}

extension WebImportSuccessScreenLocalDataController {
    private func publish(
        _ event: WebImportSuccessScreenDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
