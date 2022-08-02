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

//   SortAccountAssetListDataController.swift

import Foundation
import UIKit

protocol SortAccountAssetListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SortAccountAssetListSection, SortAccountAssetListItem>

    var eventHandler: ((SortAccountAssetListDataControllerEvent) -> Void)? { get set }

    var selectedSortingAlgorithm: AccountAssetSortingAlgorithm { get }

    func load()

    func selectItem(
        at indexPath: IndexPath
    )

    func performChanges()
}

enum SortAccountAssetListSection: Hashable {
    case sortOptions
}

enum SortAccountAssetListItem: Hashable {
    case sortOption(SelectionValue<SingleSelectionViewModel>)
}

enum SortAccountAssetListDataControllerEvent {
    case didUpdate(SortAccountAssetListDataController.Snapshot)
    case didComplete

    var snapshot: SortAccountAssetListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        default: return nil
        }
    }
}
