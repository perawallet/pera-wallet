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
//   AssetListViewDataController.swift

import Foundation
import UIKit

protocol AssetListViewDataController: AnyObject {
    typealias SectionIdentifier = OptInAssetList.SectionIdentifier
    typealias ItemIdentifier = OptInAssetList.ItemIdentifier
    typealias Snapshot = OptInAssetList.Snapshot
    typealias EventHandler = (AssetListDataControllerEvent) -> Void

    var eventHandler: EventHandler? { get set }

    var account: Account { get }

    subscript (assetID: AssetID) -> AssetDecoration? { get }
    subscript (assetID: AssetID) -> OptInAssetListItemViewModel? { get }

    func load(query: OptInAssetListQuery?)
    func loadMore()
    /// <note>
    /// It should be called for loading more after it is failed last time.
    func loadMoreAgain()
    func cancel()

    func hasOptedIn(_ asset: AssetDecoration) -> OptInStatus
}

enum AssetListDataControllerEvent {
    typealias Snapshot = OptInAssetList.Snapshot

    case didUpdateAccount
    case didReload(Snapshot)
    case didUpdate(Snapshot)
}

enum OptInAssetList {}

extension OptInAssetList {
    enum SectionIdentifier: Hashable {
        case noContent
        case content
        case waitingForMore
    }

    enum ItemIdentifier: Hashable {
        case loading
        case loadingFailed(ErrorItem)
        case notFound
        case asset(AssetItem)
        case loadingMore
        case loadingMoreFailed(ErrorItem)
    }

    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
}

extension OptInAssetList {
    struct AssetItem: Hashable {
        let assetID: AssetID
    }
}

extension OptInAssetList {
    struct ErrorItem: Hashable {
        let title: String?
        let body: String?
    }
}
