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

//   WCConnectionAccountListLocalDataController.swift

import Foundation
import MacaroonUtils
import OrderedCollections

final class WCConnectionAccountListLocalDataController: WCConnectionAccountListDataController {
    var eventHandler: ((WCConnectionAccountListDataControllerEvent) -> Void)?
    
    private lazy var accounts: OrderedDictionary<Index, Account> = [:]
    private lazy var selectedAccounts: OrderedDictionary<Index, Account> = [:]
    
    private let snapshotQueue = DispatchQueue(label: "wcConnectionAccountListSnapshot")
    
    private let sharedDataController: SharedDataController
    
    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
    }
    
    func load() {
        deliverContentSnapshot()
    }
}

extension WCConnectionAccountListLocalDataController {
    var hasSingleAccount: Bool {
        return accounts.isSingular
    }
    
    var isConnectActionEnabled: Bool {
        return !selectedAccounts.isEmpty
    }
    
    func getSelectedAccounts() -> [Account] {
        return selectedAccounts.values.elements
    }
    
    func getSelectedAccountsAddresses() -> [String] {
        return getSelectedAccounts().map {
            $0.address
        }
    }
    
    func selectAccountItem(at index: Index) {
        guard let selectedAccount = accounts[index] else {
            return
        }
        
        selectedAccounts[index] = selectedAccount
    }
    
    func unselectAccountItem(at index: Index) {
        selectedAccounts[index] = nil
    }
    
    func isAccountSelected(at index: Index) -> Bool {
        return selectedAccounts[index] != nil
    }
    
    func numberOfAccounts() -> Int {
        return accounts.count
    }
}

extension WCConnectionAccountListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
         
            self.addAccountItems(&snapshot)
            
            return snapshot
        }
    }
    
    private func addAccountItems(
        _ snapshot: inout Snapshot
    ) {
        let accounts: [Account] = self.sharedDataController
            .sortedAccounts()
            .filter {
                return !$0.value.isWatchAccount()
            }.map {
                $0.value
            }
        
        snapshot.appendSections([.accounts])
        
        let accountItems: [WCConnectionAccountListItemIdentifier] = accounts
            .enumerated()
            .map {
                let account = $0.element
                let draft = IconWithShortAddressDraft(account)
                let viewModel = AccountListItemViewModel(draft)
                
                let item = WCConnectionAccountItemIdentifier(
                    model: account,
                    viewModel: viewModel
                )
                
                self.accounts[$0.offset] = account
                
                return .account(item)
            }
        
        snapshot.appendItems(
            accountItems,
            toSection: .accounts
        )
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
    
    private func publish(
        _ event: WCConnectionAccountListDataControllerEvent
    ) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }
            
            self.eventHandler?(event)
        }
    }
}
