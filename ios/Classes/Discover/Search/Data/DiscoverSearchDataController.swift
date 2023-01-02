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

//   DiscoverSearchDataController.swift

import Foundation
import MagpieCore
import MagpieHipo
import UIKit

protocol DiscoverSearchDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<DiscoverSearchListSection, DiscoverSearchListItem>
    typealias EventHandler = (DiscoverSearchDataControllerEvent) -> Void

    var eventHandler: EventHandler? { get set }

    subscript (assetID: AssetID) -> AssetDecoration? { get }
    subscript (assetID: AssetID) -> DiscoverSearchAssetListItemViewModel? { get }

    func loadListData(query: DiscoverSearchQuery?)
    func loadNextListData()
    func cancelLoadingListData()
}

extension DiscoverSearchDataController {
    func searchAssetListItemViewModel(for assetID: AssetID) -> DiscoverSearchAssetListItemViewModel? {
        return self[assetID]
    }
}

struct DiscoverSearchQuery {
    var keyword: String?
}

enum DiscoverSearchListSection: Hashable {
    case noContent
    case list
    case nextList
}

enum DiscoverSearchListItem: Hashable {
    case loading
    case notFound
    case error(DiscoverSearchErrorItem)
    case asset(DiscoverSearchAssetListItem)
    case nextLoading
    case nextError(DiscoverSearchErrorItem)
}

struct DiscoverSearchErrorItem: Hashable {
    let title: String?
    let body: String?
}

struct DiscoverSearchAssetListItem: Hashable {
    let assetID: AssetID
}

enum DiscoverSearchDataControllerEvent {
    case didReload(DiscoverSearchDataController.Snapshot)
    case didUpdate(DiscoverSearchDataController.Snapshot)
}
