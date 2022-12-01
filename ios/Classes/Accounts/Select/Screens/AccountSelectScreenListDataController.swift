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

//   AccountSelectScreenListDataController.swift

import Foundation
import UIKit

protocol AccountSelectScreenListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountSelectSection, AccountSelectItem>

    var eventHandler: ((AccountSelectScreenListDataControllerEvent) -> Void)? { get set }

    var lastSnapshot: Snapshot? { get }

    subscript (address: String?) -> AccountHandle? { get }

    func load()
    func reload()
    func search(query: String?)

    func account(at indexPath: IndexPath) -> Account?
    func contact(at indexPath: IndexPath) -> Contact?
    func searchedAccount(at indexPath: IndexPath) -> Account?
    func matchedAccount(at indexPath: IndexPath) -> NameService?
}

enum AccountSelectSection:
    Int,
    Hashable {
    case empty
    case matched
    case accounts
    case contacts
    case searchResult
}

enum AccountSelectItem: Hashable {
    case empty(AccountSelectEmptyItem)
    case account(AccountSelectAccountItem)
}

enum AccountSelectEmptyItem: Hashable {
    case loading
    case noContent(AccountSelectNoContentViewModel)
}

enum AccountSelectAccountItem: Hashable {
    case header(SelectAccountHeaderViewModel)
    case accountCell(AccountListItemViewModel)
    case contactCell(ContactsViewModel)
    case searchAccountCell(AccountListItemViewModel)
    case matchedAccountCell(AccountListItemViewModel)
}

enum AccountSelectScreenListDataControllerEvent {
    case didUpdate(AccountSelectScreenListDataController.Snapshot)

    var snapshot: AccountSelectScreenListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
