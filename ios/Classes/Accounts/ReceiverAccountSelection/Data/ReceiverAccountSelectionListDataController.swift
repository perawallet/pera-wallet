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

//   ReceiverAccountSelectionListDataController.swift

import UIKit

protocol ReceiverAccountSelectionListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ReceiverAccountSelectionListSection, ReceiverAccountSelectionListItem>

    var eventHandler: ((ReceiverAccountSelectionListDataControllerEvent) -> Void)? { get set }

    var accountGeneratedFromQuery: Account? { get }

    func load()
    func search(for query: String?)
    func resetSearch()

    typealias Address = String
    subscript(accountAddress address: Address) -> Account? { get }
    subscript(contactAddress address: Address) -> Contact? { get }
    subscript(nameServiceAddress address: Address) -> NameService? { get }
}

enum ReceiverAccountSelectionListSection:
    Hashable {
    case empty
    case loading
    case accounts
    case contacts
    case nameServiceAccounts
}

enum ReceiverAccountSelectionListItem: Hashable {
    case empty(ReceiveCollectibleAssetListEmptyItem)
    case header(ReceiverAccountSelectionListHeaderViewModel)
    case account(viewModel: AccountListItemViewModel, isPreviouslySelected: Bool)
    case accountGeneratedFromQuery(viewModel: AccountListItemViewModel, isPreviouslySelected: Bool)
    case contact(viewModel: ContactsViewModel, isPreviouslySelected: Bool)
    case nameServiceAccount(viewModel: AccountListItemViewModel, isPreviouslySelected: Bool)
}

enum ReceiverAccountSelectionListEmptyItem: Hashable {
    case loading(String)
    case noContent
}

enum ReceiverAccountSelectionListDataControllerEvent {
    case didUpdate(ReceiverAccountSelectionListDataController.Snapshot, isLoading: Bool)

    var snapshot: ReceiverAccountSelectionListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot, _):
            return snapshot
        }
    }
}
