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

    func load()
    func loadNextPageIfNeeded(for indexPath: IndexPath)
    func search(for query: String?)
    func resetSearch()
    
    subscript(index: Int) -> AssetDecoration? { get }
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
    case collectible(AssetPreviewViewModel)
}

enum ReceiveCollectibleAssetListEmptyItem: Hashable {
    case loading(String)
    case noContent
}

enum ReceiveCollectibleAssetListDataControllerEvent {
    case didUpdate(ReceiveCollectibleAssetListDataController.Snapshot)

    var snapshot: ReceiveCollectibleAssetListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        }
    }
}
