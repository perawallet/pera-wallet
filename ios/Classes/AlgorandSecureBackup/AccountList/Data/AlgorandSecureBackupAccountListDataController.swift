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

//   AlgorandSecureBackupAccountListDataController.swift

import Foundation
import UIKit
import OrderedCollections

protocol AlgorandSecureBackupAccountListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AlgorandSecureBackupAccountListSectionIdentifier, AlgorandSecureBackupAccountListItemIdentifier>

    var eventHandler: ((AlgorandSecureBackupAccountListDataControllerEvent) -> Void)? { get set }

    var hasSingleAccount: Bool { get }
    var isContinueActionEnabled: Bool { get }

    func load()

    func getSelectedAccounts() -> [Account]

    var accountsHeaderViewModel: AlgorandSecureBackupAccountListAccountsHeaderViewModel! { get }
    func getAccountsHeaderItemState() -> AlgorandSecureBackupAccountListAccountHeaderItemState

    typealias Index = Int
    func selectAccountItem(at index: Index)
    func unselectAccountItem(at index: Index)
    func selectAllAccountsItems()
    func unselectAllAccountsItems()
    func isAccountSelected(at index: Index) -> Bool
}

enum AlgorandSecureBackupAccountListSectionIdentifier:
    Hashable {
    case accounts
    case empty
}

enum AlgorandSecureBackupAccountListItemIdentifier: Hashable {
    case account(AlgorandSecureBackupAccountListAccountItemIdentifier)
    case noContent
}

enum AlgorandSecureBackupAccountListAccountItemIdentifier: Hashable {
    case header(AlgorandSecureBackupAccountListAccountsHeaderViewModel)
    case cell(AlgorandSecureBackupAccountListAccountCellItemIdentifier)
}

struct AlgorandSecureBackupAccountListAccountCellItemIdentifier:
    Hashable {
    private(set) var model: Account
    private(set) var viewModel: AccountListItemViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.address)
    }

    static func == (
        lhs: AlgorandSecureBackupAccountListAccountCellItemIdentifier,
        rhs: AlgorandSecureBackupAccountListAccountCellItemIdentifier
    ) -> Bool {
        return lhs.model.address == rhs.model.address
    }
}

enum AlgorandSecureBackupAccountListDataControllerEvent {
    case didUpdate(AlgorandSecureBackupAccountListDataController.Snapshot)

    var snapshot: AlgorandSecureBackupAccountListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
