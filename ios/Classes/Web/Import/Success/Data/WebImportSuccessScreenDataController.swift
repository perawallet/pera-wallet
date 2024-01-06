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

//   WebImportSuccessScreenDataController.swift

import Foundation
import UIKit

protocol WebImportSuccessScreenDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<WebImportSuccessListViewSection, WebImportSuccessListViewItem>

    subscript (address: String) -> Account? { get }
    subscript (address: String) -> AccountListItemViewModel? { get }

    var eventHandler: ((WebImportSuccessScreenDataControllerEvent) -> Void)? { get set }

    func load()
}

extension WebImportSuccessScreenDataController {
    func accountListItemViewModel(for accountAddress: String) -> AccountListItemViewModel? {
        self[accountAddress]
    }
}

enum WebImportSuccessListViewSection:
    Int,
    Hashable {
    case accounts
}

enum WebImportSuccessListViewItem: Hashable {
    case header(WebImportSuccessListHeaderItem)
    case asbHeader(WebImportSuccessListHeaderItem)
    case missingAccounts(WebImportSuccessListMissingAccountItem)
    case asbMissingAccounts(WebImportSuccessListMissingAccountItem)
    case account(WebImportSuccessListViewAccountItem)
}

struct WebImportSuccessListHeaderItem: Hashable {
    let importedAccountCount: Int
}

struct WebImportSuccessListMissingAccountItem: Hashable {
    let unimportedAccountCount: Int
    let unsupportedAccountCount: Int
}

struct WebImportSuccessListViewAccountItem: Hashable {
    let accountAddress: String
}

enum WebImportSuccessScreenDataControllerEvent {
    case didUpdate(WebImportSuccessScreenDataController.Snapshot)

    var snapshot: WebImportSuccessScreenDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
