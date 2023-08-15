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

//   RekeyedAccountSelectionListDataController.swift

import Foundation
import UIKit
import OrderedCollections

protocol RekeyedAccountSelectionListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<RekeyedAccountSelectionListSectionIdentifier, RekeyedAccountSelectionListItemIdentifier>

    var eventHandler: ((RekeyedAccountSelectionListDataControllerEvent) -> Void)? { get set }

    var authAccount: Account { get }

    var hasSingleAccount: Bool { get }
    var isPrimaryActionEnabled: Bool { get }

    func load()

    func getAccounts() -> [Account]
    func getSelectedAccounts() -> [Account]

    typealias Index = Int
    func selectAccountItem(at index: Index)
    func unselectAccountItem(at index: Index)
    func isAccountSelected(at index: Index) -> Bool
}

enum RekeyedAccountSelectionListSectionIdentifier:
    Hashable {
    case accounts
}

enum RekeyedAccountSelectionListItemIdentifier: Hashable {
    case account(RekeyedAccountSelectionListAccountCellItemIdentifier)
    case accountLoading
}

struct RekeyedAccountSelectionListAccountCellItemIdentifier:
    Hashable {
    private(set) var model: Account
    private(set) var viewModel: LedgerAccountViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.address)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.model.address == rhs.model.address
    }
}

enum RekeyedAccountSelectionListDataControllerEvent {
    case didUpdate(RekeyedAccountSelectionListDataController.Snapshot)

    var snapshot: RekeyedAccountSelectionListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
