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

//   WCConnectionAccountListDataController.swift

import UIKit

protocol WCConnectionAccountListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<WCConnectionAccountListSectionIdentifier, WCConnectionAccountListItemIdentifier>
    
    var eventHandler: ((WCConnectionAccountListDataControllerEvent) -> Void)? { get set }
    
    var hasSingleAccount: Bool { get }
    var isConnectActionEnabled: Bool { get }
    
    func load()
    
    func getSelectedAccounts() -> [Account]
    func getSelectedAccountsAddresses() -> [String]
    
    typealias Index = Int
    func selectAccountItem(at index: Index)
    func unselectAccountItem(at index: Index)
    func isAccountSelected(at index: Index) -> Bool
    func numberOfAccounts() -> Int
}

enum WCConnectionAccountListSectionIdentifier: Hashable {
    case accounts
}

enum WCConnectionAccountListItemIdentifier: Hashable {
    case account(WCConnectionAccountItemIdentifier)
}

struct WCConnectionAccountItemIdentifier: Hashable {
    private(set) var model: Account
    private(set) var viewModel: AccountListItemViewModel
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(model.address)
    }
    
    static func == (
        lhs: WCConnectionAccountItemIdentifier,
        rhs: WCConnectionAccountItemIdentifier
    ) -> Bool {
        return lhs.model.address == rhs.model.address
    }
}

enum WCConnectionAccountListDataControllerEvent {
    case didUpdate(WCConnectionAccountListDataController.Snapshot)
    
    var snapshot: WCConnectionAccountListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
