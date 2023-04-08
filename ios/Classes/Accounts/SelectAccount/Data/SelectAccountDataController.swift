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
//   SelectAccountDataController.swift

import Foundation
import UIKit

protocol SelectAccountDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SelectAccountListViewSection, SelectAccountListViewItem>

    var eventHandler: ((SelectAccountDataControllerEvent) -> Void)? { get set }

    func load()
}

enum SelectAccountListViewSection:
    Int,
    Hashable {
    case accounts
    case empty
}

enum SelectAccountListViewItem: Hashable {
    case account(AccountListItemViewModel, AccountHandle)
    case empty(SelectAccountListEmptyItem)
}

enum SelectAccountListEmptyItem: Hashable {
    case loading(String)
    case noContent(SelectAccountNoContentViewModel)
}

enum SelectAccountDataControllerEvent {
    case didUpdate(SelectAccountDataController.Snapshot)

    var snapshot: SelectAccountDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
