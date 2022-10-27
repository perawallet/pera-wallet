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

//   ExportAccountListDataController.swift

import Foundation
import UIKit
import OrderedCollections

protocol ExportAccountListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ExportAccountListSectionIdentifier, ExportAccountListItemIdentifier>

    var eventHandler: ((ExportAccountListDataControllerEvent) -> Void)? { get set }

    var hasAccounts: Bool { get }
    var hasSingleAccount: Bool { get }
    var isContinueActionEnabled: Bool { get }

    func load()

    func getSelectedAccounts() -> [Account]

    var accountsHeaderViewModel: ExportAccountListAccountsHeaderViewModel! { get }
    func getAccountsHeaderItemState() -> ExportAccountListAccountHeaderItemState

    typealias Index = Int
    func selectAccountItem(at index: Index)
    func unselectAccountItem(at index: Index)
    func selectAllAccountsItems()
    func unselectAllAccountsItems()
    func isAccountSelected(at index: Index) -> Bool
}

enum ExportAccountListSectionIdentifier:
    Hashable {
    case accounts
    case empty
}

enum ExportAccountListItemIdentifier: Hashable {
    case account(ExportAccountListAccountItemIdentifier)
    case noContent
}

enum ExportAccountListAccountItemIdentifier: Hashable {
    case header(ExportAccountListAccountsHeaderViewModel)
    case cell(ExportAccountListAccountCellItemIdentifier)
}

struct ExportAccountListAccountCellItemIdentifier:
    Hashable {
    private(set) var model: Account
    private(set) var viewModel: AccountPreviewViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.address)
    }

    static func == (
        lhs: ExportAccountListAccountCellItemIdentifier,
        rhs: ExportAccountListAccountCellItemIdentifier
    ) -> Bool {
        return lhs.model.address == rhs.model.address
    }
}

enum ExportAccountListDataControllerEvent {
    case didUpdate(ExportAccountListDataController.Snapshot)

    var snapshot: ExportAccountListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
