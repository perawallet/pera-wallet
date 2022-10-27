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

//   CollectibleDetailDataController.swift

import Foundation
import UIKit
import MagpieCore

protocol CollectibleDetailDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<CollectibleDetailSection, CollectibleDetailItem>

    var eventHandler: ((CollectibleDetailDataControllerEvent) -> Void)? { get set }

    func load()
    func retry()

    func hasOptedIn() -> OptInStatus
    func hasOptedOut() -> OptOutStatus
}

enum CollectibleDetailSection:
    Int,
    Hashable {
    case media
    case action
    case description
    case properties
    case external
    case loading
}

enum CollectibleDetailItem: Hashable {
    case loading
    case error(CollectibleMediaErrorViewModel)
    case media(CollectibleAsset)
    case action(CollectibleDetailActionViewModel)
    case watchAccountAction(CollectibleDetailActionViewModel)
    case collectibleCreatorAccountAction(CollectibleDetailActionViewModel)
    case optedInAction(CollectibleDetailOptedInActionViewModel)
    case description(CollectibleDescriptionViewModel)
    case assetID(CollectibleDetailAssetIDItemIdentifier)
    case information(CollectibleTransactionInformation)
    case properties(CollectiblePropertyViewModel)
    case external(CollectibleExternalSourceViewModel)
}

struct CollectibleDetailAssetIDItemIdentifier: Hashable {
    private let id = UUID()
    let viewModel: CollectibleDetailAssetIDItemViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.id == rhs.id
    }
}

enum CollectibleDetailDataControllerEvent {
    case didUpdate(CollectibleDetailDataController.Snapshot)
    case didFetch(CollectibleAsset)
    case didResponseFail(message: String)

    var snapshot: CollectibleDetailDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        default:
            return nil
        }
    }
}
