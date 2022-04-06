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

//   CollectibleListDataController.swift

import Foundation
import UIKit
import MacaroonUIKit

protocol CollectibleListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<CollectibleSection, CollectibleListItem>

    var eventHandler: ((CollectibleDataControllerEvent) -> Void)? { get set }

    var imageSize: CGSize { get set }

    func load()
    func search(for query: String)
    func resetSearch()
}

enum CollectibleSection:
    Int,
    Hashable {
    case empty
    case loading
    case search
    case collectibles
}

enum CollectibleListItem: Hashable {
    case empty(CollectibleEmptyItem)
    case search
    case collectible(CollectibleItem)
}

enum CollectibleEmptyItem: Hashable {
    case loading
    case noContent
    case noContentSearch
}

enum CollectibleItem: Hashable {
    case cell(CollectibleCellItem)
    case footer
}

enum CollectibleCellItem: Hashable {
    case owner(CollectibleCellItemContainer<CollectibleListItemReadyViewModel>)
    case optedIn(CollectibleCellItemContainer<CollectibleListItemReadyViewModel>)
    case pending(CollectibleCellItemContainer<CollectibleListItemPendingViewModel>)
}

struct CollectibleCellItemContainer<T: ViewModel & Hashable>: Hashable {
    let account: Account
    let asset: CollectibleAsset
    let viewModel: T
}

enum CollectibleDataControllerEvent {
    case didUpdate(CollectibleListDataController.Snapshot)

    var snapshot: CollectibleListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}
