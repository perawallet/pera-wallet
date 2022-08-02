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

//   SortCollectibleListDataController.swift

import Foundation
import UIKit

protocol SortCollectibleListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SortCollectibleListSection, SortCollectibleListItem>

    var eventHandler: ((SortCollectibleListDataControllerEvent) -> Void)? { get set }

    var selectedSortingAlgorithm: CollectibleSortingAlgorithm { get }

    func load()

    func selectItem(
        at indexPath: IndexPath
    )

    func performChanges()
}

enum SortCollectibleListSection: Hashable {
    case sortOptions
}

enum SortCollectibleListItem: Hashable {
    case sortOption(SelectionValue<SingleSelectionViewModel>)
}

enum SortCollectibleListDataControllerEvent {
    case didUpdate(SortCollectibleListDataController.Snapshot)
    case didComplete

    var snapshot: SortCollectibleListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        default: return nil
        }
    }
}
