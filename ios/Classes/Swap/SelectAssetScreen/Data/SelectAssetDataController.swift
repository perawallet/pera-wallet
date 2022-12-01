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

//   SelectAssetDataController.swift

import Foundation
import MagpieCore
import MagpieExceptions
import MagpieHipo
import UIKit

protocol SelectAssetDataController: AnyObject {
    typealias EventHandler = (SelectAssetDataControllerEvent) -> Void
    typealias Error = HIPNetworkError<HIPAPIError>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SelectAssetSection, SelectAssetItem>
    typealias Updates = (snapshot: Snapshot, error: Error?)

    var eventHandler: EventHandler? { get set }
    var account: Account { get }

    subscript(indexPath: IndexPath) -> Asset? { get }
    subscript(id: AssetID) -> Asset? { get }

    func load()
    func search(for query: String?)
    func resetSearch()
}

enum SelectAssetSection:
    Int,
    Hashable {
    case assets
    case empty
    case error
}

enum SelectAssetItem: Hashable {
    case asset(SelectAssetListItem)
    case empty(SelectAssetEmptyItem)
    case error(SelectAssetErrorItemViewModel)
}

enum SelectAssetEmptyItem: Hashable {
    case noContent(SelectAssetNoContentItemViewModel)
    case loading(String)
}

enum SelectAssetDataControllerEvent {
    case didUpdate(SelectAssetDataController.Updates)
}
