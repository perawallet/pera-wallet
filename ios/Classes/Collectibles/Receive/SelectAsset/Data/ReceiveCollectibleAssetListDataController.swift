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

//   ReceiveCollectibleAssetListDataController.swift

import UIKit

protocol ReceiveCollectibleAssetListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ReceiveCollectibleAssetListSection, ReceiveCollectibleAssetListItem>

    var eventHandler: ((ReceiveCollectibleAssetListDataControllerEvent) -> Void)? { get set }

    var account: Account { get }

    func load()
    func loadNextPageIfNeeded(for indexPath: IndexPath)
    func search(for query: String?)
    
    subscript(index: Int) -> AssetDecoration? { get }

    func hasOptedIn(_ asset: AssetDecoration) -> OptInStatus
}

enum ReceiveCollectibleAssetListSection:
    Hashable {
    case empty
    case loading
    case info
    case search
    case collectibles
}

enum ReceiveCollectibleAssetListItem: Hashable {
    case empty(ReceiveCollectibleAssetListEmptyItem)
    case info
    case search
    case collectible(OptInAssetListItem)
}

enum ReceiveCollectibleAssetListEmptyItem: Hashable {
    case loading(String)
    case noContent
}

enum ReceiveCollectibleAssetListDataControllerEvent {
    case didUpdateAccount
    case didUpdateAssets(ReceiveCollectibleAssetListDataController.Snapshot)
}
