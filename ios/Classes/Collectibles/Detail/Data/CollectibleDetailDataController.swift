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
    func reloadAfterOptInStatusUpdates()

    func hasOptedIn() -> OptInStatus
    func hasOptedOut() -> OptOutStatus
    func getCurrentAccountCollectibleStatus() -> AccountCollectibleStatus
}

enum CollectibleDetailSection:
    Int,
    Hashable {
    case name
    case accountInformation
    case media
    case action
    case properties
    case description
    case loading
}

enum CollectibleDetailItem: Hashable {
    case loading
    case error(CollectibleMediaErrorViewModel)
    case name(CollectibleDetailNameItemIdentifier)
    case accountInformation(CollectibleDetailAccountInformationItemIdentifier)
    case media(CollectibleAsset)
    case sendAction
    case optOutAction
    case description
    case creatorAccount(CollectibleDetailCreatorAccountItemIdentifier)
    case assetID(CollectibleDetailAssetIDItemIdentifier)
    case information(CollectibleTransactionInformation)
    case properties(CollectiblePropertyViewModel)
}

struct CollectibleDetailNameItemIdentifier: Hashable {
    private let name: String
    let viewModel: CollectibleDetailNameViewModel

    init(_ asset: CollectibleAsset) {
        self.name = asset.naming.name.unwrapNonEmptyString() ?? "title-unknown".localized
        self.viewModel = CollectibleDetailNameViewModel(asset)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.name == rhs.name
    }
}

struct CollectibleDetailAccountInformationItemIdentifier: Hashable {
    private let id: String
    let viewModel: CollectibleDetailAccountInformationViewModel

    init(_ item: CollectibleAssetItem) {
        self.id = item.asset.amount.description.appending(item.account.primaryDisplayName)
        self.viewModel = CollectibleDetailAccountInformationViewModel(item)
    }

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

struct CollectibleDetailAssetIDItemIdentifier: Hashable {
    private let assetID: AssetID
    let viewModel: CollectibleDetailAssetIDItemViewModel

    init(_ asset: CollectibleAsset) {
        self.assetID = asset.id
        self.viewModel = CollectibleDetailAssetIDItemViewModel(asset: asset)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetID)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.assetID == rhs.assetID
    }
}

struct CollectibleDetailCreatorAccountItemIdentifier: Hashable {
    private let address: PublicKey
    let viewModel: CollectibleDetailCreatorAccountItemViewModel

    init(_ asset: CollectibleAsset) {
        self.address = asset.creator!.address
        self.viewModel = CollectibleDetailCreatorAccountItemViewModel(asset: asset)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.address == rhs.address
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

enum AccountCollectibleStatus {
    case notOptedIn
    case optingOut /// Waiting for syncing
    case optingIn /// Waiting for syncing
    case optedIn
    case owned
}
