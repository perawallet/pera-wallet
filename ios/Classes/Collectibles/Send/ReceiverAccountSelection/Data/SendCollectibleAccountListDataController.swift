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

//   SendCollectibleAccountListDataController.swift

import UIKit

protocol SendCollectibleAccountListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SendCollectibleAccountListSection, SendCollectibleAccountListItem>

    var eventHandler: ((SendCollectibleAccountListDataControllerEvent) -> Void)? { get set }

    func load()
    func search(for query: String?)
    func resetSearch()

    typealias Address = String
    subscript(accountAddress address: Address) -> Account? { get }
    subscript(contactAddress address: Address) -> Contact? { get }
}

enum SendCollectibleAccountListSection:
    Hashable {
    case empty
    case loading
    case accounts
    case contacts
}

enum SendCollectibleAccountListItem: Hashable {
    case empty(ReceiveCollectibleAssetListEmptyItem)
    case header(SendCollectibleAccountListHeaderViewModel)
    case account(viewModel: AccountListItemViewModel, isPreviouslySelected: Bool)
    case contact(viewModel: ContactsViewModel, isPreviouslySelected: Bool)
}

enum SendCollectibleAccountListEmptyItem: Hashable {
    case loading(String)
    case noContent
}

enum SendCollectibleAccountListDataControllerEvent {
    case didUpdate(SendCollectibleAccountListDataController.Snapshot)

    var snapshot: SendCollectibleAccountListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        }
    }
}
