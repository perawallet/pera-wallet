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

//   ManageAssetsListDataController.swift

import Foundation
import UIKit

protocol ManageAssetsListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ManageAssetSearchSection, ManageAssetSearchItem>

    var eventHandler: ((ManageAssetsListDataControllerEvent) -> Void)? { get set }

    var account: Account { get }
    var dataSource: ManageAssetsListDataSource? { get set }

    subscript(index: Int) -> Asset? { get }
    subscript(assetID: AssetID) -> Asset? { get }

    func search(for query: String)
    func resetSearch()
    func hasOptedOut(
        _ asset: Asset
    ) -> OptOutStatus
}

enum ManageAssetsListDataControllerEvent {
    case didUpdate(ManageAssetsListDataController.Snapshot)
}

enum ManageAssetSearchSection:
    Int,
    Hashable {
    case assets
    case empty
}

enum ManageAssetSearchItem: Hashable {
    case asset(OptOutAssetListItem)
    case empty(AssetListSearchNoContentViewModel)
}
