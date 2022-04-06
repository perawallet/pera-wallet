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
//   AssetSearchDataController.swift

import Foundation
import UIKit

protocol AssetSearchDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AssetSearchSection, AssetSearchItem>

    var eventHandler: ((AssetSearchDataControllerEvent) -> Void)? { get set }

    func load()
    func search(for query: String)
    func resetSearch()

    subscript(index: Int) -> StandardAsset? { get }
}

enum AssetSearchSection:
    Int,
    Hashable {
    case assets
    case empty
}

enum AssetSearchItem: Hashable {
    case header(AssetSearchListHeaderViewModel)
    case asset(AssetPreviewViewModel)
    case empty(AssetListSearchNoContentViewModel)
}

enum AssetSearchDataControllerEvent {
    case didUpdate(AssetSearchDataController.Snapshot)
}
