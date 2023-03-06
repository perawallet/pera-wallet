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
    typealias Snapshot = NSDiffableDataSourceSnapshot<AssetListViewSection, AssetListViewItem>

    var eventHandler: ((AssetListViewDataControllerEvent) -> Void)? { get set }

    var account: Account { get }

    func load()
    func loadNextPageIfNeeded(for indexPath: IndexPath)
    func search(for query: String?)

    func hasOptedIn(_ asset: AssetDecoration) -> OptInStatus
}

enum AssetListViewSection:
    Int,
    Hashable {
    case assets
    case empty
}

enum AssetListViewItem: Hashable {
    case asset(OptInAssetListItem)
    case loading(String)
    case noContent
}

enum AssetListViewDataControllerEvent {
    case didUpdateAccount
    case didUpdateAssets(AssetListViewDataController.Snapshot)
    case didUpdateNextAssets(AssetListViewDataController.Snapshot)
}
