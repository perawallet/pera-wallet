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
    var eventHandler: ((CollectibleDataControllerEvent) -> Void)? { get set }

    var imageSize: CGSize { get set }

    var galleryAccount: CollectibleGalleryAccount { get }
    var galleryUIStyle: CollectibleGalleryUIStyle { get set }

    func load(query: CollectibleListQuery?)
    func load(galleryUIStyle: CollectibleGalleryUIStyle)

    func startUpdates()
    func stopUpdates()
}

enum CollectibleSection:
    Int,
    Hashable {
    case empty
    case header
    case uiActions
    case collectibles
}

enum CollectibleListItem: Hashable {
    case empty(CollectibleEmptyItem)
    case header(ManagementItemViewModel)
    case watchAccountHeader(ManagementItemViewModel)
    case uiActions
    case collectibleAsset(CollectibleGalleryCollectibleAssetItem)
    case collectibleAssetsLoading(CollectibleGalleryCollectibleAssetsLoadingItem)
    case pendingCollectibleAsset(CollectibleGalleryPendingCollectibleAssetItem)
}

enum CollectibleGalleryCollectibleAssetsLoadingItem: Hashable {
    case grid
    case list
}

enum CollectibleGalleryCollectibleAssetItem: Hashable {
    case grid(CollectibleListCollectibleAssetGridItem)
    case list(CollectibleListCollectibleAssetListItem)
}

enum CollectibleGalleryPendingCollectibleAssetItem: Hashable {
    case grid(CollectibleListPendingCollectibleAssetGridItem)
    case list(CollectibleListPendingCollectibleAssetListItem)
}

enum CollectibleEmptyItem: Hashable {
    case noContent(CollectiblesNoContentWithActionViewModel)
    case noContentSearch
}

struct CollectibleListCollectibleAssetGridItem: Hashable {
    let account: Account
    let asset: CollectibleAsset
    let viewModel: CollectibleGridItemViewModel

    init(imageSize: CGSize, item: CollectibleAssetItem) {
        self.account = item.account
        self.asset = item.asset
        self.viewModel = CollectibleGridItemViewModel(imageSize: imageSize, model: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(asset.amount)
        hasher.combine(account.address)
        hasher.combine(viewModel.title?.string)
        hasher.combine(viewModel.subtitle?.string)
    }

    static func == (
        lhs: CollectibleListCollectibleAssetGridItem,
        rhs: CollectibleListCollectibleAssetGridItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.asset.amount == rhs.asset.amount &&
            lhs.account.address == rhs.account.address &&
            lhs.viewModel.title?.string == rhs.viewModel.title?.string &&
            lhs.viewModel.subtitle?.string == rhs.viewModel.subtitle?.string
    }
}

struct CollectibleListPendingCollectibleAssetGridItem: Hashable {
    let viewModel: CollectibleGridItemViewModel

    private let accountAddress: PublicKey
    private let assetID: AssetID
    
    init(imageSize: CGSize, update: OptInBlockchainUpdate) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.viewModel = CollectibleGridItemViewModel(imageSize: imageSize, model: update)
    }

    init(imageSize: CGSize, update: OptOutBlockchainUpdate) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.viewModel = CollectibleGridItemViewModel(imageSize: imageSize, model: update)
    }

    init(imageSize: CGSize, update: SendPureCollectibleAssetBlockchainUpdate) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.viewModel = CollectibleGridItemViewModel(imageSize: imageSize, model: update)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetID)
        hasher.combine(accountAddress)
    }

    static func == (
        lhs: CollectibleListPendingCollectibleAssetGridItem,
        rhs: CollectibleListPendingCollectibleAssetGridItem
    ) -> Bool {
        return
            lhs.assetID == rhs.assetID &&
            lhs.accountAddress == rhs.accountAddress
    }
}

struct CollectibleListCollectibleAssetListItem: Hashable {
    let account: Account
    let asset: CollectibleAsset
    let viewModel: CollectibleListItemViewModel

    init(item: CollectibleAssetItem) {
        self.account = item.account
        self.asset = item.asset
        self.viewModel = CollectibleListItemViewModel(item: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(asset.amount)
        hasher.combine(account.address)
        hasher.combine(viewModel.primaryTitle?.string)
        hasher.combine(viewModel.secondaryTitle?.string)
    }

    static func == (
        lhs: CollectibleListCollectibleAssetListItem,
        rhs: CollectibleListCollectibleAssetListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.asset.amount == rhs.asset.amount &&
            lhs.account.address == rhs.account.address &&
            lhs.viewModel.primaryTitle?.string == rhs.viewModel.primaryTitle?.string &&
            lhs.viewModel.secondaryTitle?.string == rhs.viewModel.secondaryTitle?.string
    }
}

struct CollectibleListPendingCollectibleAssetListItem: Hashable {
    let viewModel: CollectibleListItemViewModel

    private let accountAddress: PublicKey
    private let assetID: AssetID

    init(update: OptInBlockchainUpdate) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.viewModel = CollectibleListItemViewModel(update: update)
    }

    init(update: OptOutBlockchainUpdate) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.viewModel = CollectibleListItemViewModel(update: update)
    }

    init(update: SendPureCollectibleAssetBlockchainUpdate) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.viewModel = CollectibleListItemViewModel(update: update)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetID)
        hasher.combine(accountAddress)
    }

    static func == (
        lhs: CollectibleListPendingCollectibleAssetListItem,
        rhs: CollectibleListPendingCollectibleAssetListItem
    ) -> Bool {
        return
            lhs.assetID == rhs.assetID &&
            lhs.accountAddress == rhs.accountAddress
    }
}

enum CollectibleGalleryAccount {
    case single(AccountHandle)
    case all

    var singleAccount: AccountHandle? {
        switch self {
        case .single(let account): return account
        default: return nil
        }
    }

    var isAll: Bool {
        switch self {
        case .all: return true
        default: return false
        }
    }
}

extension CollectibleGalleryCollectibleAssetItem {
    var account: Account {
        switch self {
        case .grid(let item): return item.account
        case .list(let item): return item.account
        }
    }

    var asset: CollectibleAsset {
        switch self {
        case .grid(let item): return item.asset
        case .list(let item): return item.asset
        }
    }
}

enum CollectibleDataControllerEvent {
    case didUpdate(CollectibleListUpdates)
    case didFinishRunning(hasError: Bool)
}

struct CollectibleListUpdates {
    let snapshot: Snapshot
}

extension CollectibleListUpdates {
    typealias Snapshot = NSDiffableDataSourceSnapshot<CollectibleSection, CollectibleListItem>
}
