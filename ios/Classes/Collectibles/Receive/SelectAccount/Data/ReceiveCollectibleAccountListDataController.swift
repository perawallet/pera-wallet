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

//   ReceiveCollectibleAccountListDataController.swift

import UIKit

protocol ReceiveCollectibleAccountListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ReceiveCollectibleAccountListSection, ReceiveCollectibleAccountListItem>

    var eventHandler: ((ReceiveCollectibleAccountListDataControllerEvent) -> Void)? { get set }

    subscript(address: String?) -> AccountHandle? { get }

    func load()
}

enum ReceiveCollectibleAccountListSection:
    Int,
    Hashable {
    case empty
    case loading
    case info
    case header
    case accounts
}

enum ReceiveCollectibleAccountListItem: Hashable {
    case empty(ReceiveCollectibleAccountListEmptyItem)
    case info
    case header(ReceiveCollectibleAccountListHeaderViewModel)
    case account(AccountListItemViewModel)
}

enum ReceiveCollectibleAccountListEmptyItem: Hashable {
    case loading(String)
    case noContent
}

enum ReceiveCollectibleAccountListDataControllerEvent {
    case didUpdate(ReceiveCollectibleAccountListDataController.Snapshot)

    var snapshot: ReceiveCollectibleAccountListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        }
    }
}
