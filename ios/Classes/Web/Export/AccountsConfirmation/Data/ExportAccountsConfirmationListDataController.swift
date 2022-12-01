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

//   ExportAccountsConfirmationListDataController.swift

import Foundation
import UIKit

protocol ExportAccountsConfirmationListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ExportAccountsConfirmationListSectionIdentifier, ExportAccountsConfirmationListItemIdentifier>

    var eventHandler: ((ExportAccountsConfirmationListDataControllerEvent) -> Void)? { get set }

    var selectedAccounts: [Account] { get }

    func load()
}

extension ExportAccountsConfirmationListDataController {
    var hasSingularAccount: Bool {
        selectedAccounts.isSingular
    }
}

enum ExportAccountsConfirmationListSectionIdentifier:
    Hashable {
    case accounts
}

enum ExportAccountsConfirmationListItemIdentifier: Hashable {
    case account(ExportAccountsConfirmationListAccountItemIdentifier)
}

enum ExportAccountsConfirmationListAccountItemIdentifier: Hashable {
    case cell(ExportAccountsConfirmationListAccountCellItemIdentifier)
}

struct ExportAccountsConfirmationListAccountCellItemIdentifier:
    Hashable {
    private(set) var model: Account
    private(set) var viewModel: AccountListItemViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.address)
    }

    static func == (
        lhs: ExportAccountsConfirmationListAccountCellItemIdentifier,
        rhs: ExportAccountsConfirmationListAccountCellItemIdentifier
    ) -> Bool {
        return lhs.model.address == rhs.model.address
    }
}

enum ExportAccountsConfirmationListDataControllerEvent {
    case didUpdate(ExportAccountsConfirmationListDataController.Snapshot)

    var snapshot: ExportAccountsConfirmationListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
