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
//   AccountAssetListDataController.swift

import Foundation
import UIKit

protocol AccountAssetListDataController: AnyObject {
    var eventHandler: ((AccountAssetListDataControllerEvent) -> Void)? { get set }

    var account: AccountHandle { get }

    func load(query: AccountAssetListQuery?)
    func reload()
    func reloadIfNeededForPendingAssetRequests()
}

enum AccountAssetsSection:
    Int,
    Hashable {
    case accountNotBackedUpWarning
    case portfolio
    case quickActions
    case assets
    case empty
}

enum AccountAssetsItem: Hashable {
    case accountNotBackedUpWarning(AccountDetailAccountNotBackedUpWarningModel)
    case portfolio(AccountPortfolioViewModel)
    case watchPortfolio(WatchAccountPortfolioViewModel)
    case search
    case assetLoading
    case asset(AccountAssetsAssetListItem)
    case pendingAsset(AccountAssetsPendingAssetListItem)
    case collectibleAsset(AccountAssetsCollectibleAssetListItem)
    case pendingCollectibleAsset(AccountAssetsPendingCollectibleAssetListItem)
    case assetManagement(ManagementItemViewModel)
    case watchAccountAssetManagement(ManagementItemViewModel)
    case quickActions
    case watchAccountQuickActions
    case empty(AssetListSearchNoContentViewModel)
}

extension AccountAssetsItem {
    var asset: Asset? {
        switch self {
        case .asset(let item): return item.asset
        case .collectibleAsset(let item): return item.asset
        default: return nil
        }
    }
}

struct AccountAssetsAssetListItem: Hashable {
    let asset: Asset
    let viewModel: AssetListItemViewModel

    init(item: AssetItem) {
        self.asset = item.asset
        self.viewModel = AssetListItemViewModel(item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(viewModel.title?.primaryTitle?.string)
        hasher.combine(viewModel.title?.secondaryTitle?.string)
        hasher.combine(viewModel.primaryValue?.string)
        hasher.combine(viewModel.secondaryValue?.string)
    }

    static func == (
        lhs: AccountAssetsAssetListItem,
        rhs: AccountAssetsAssetListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.viewModel.title?.primaryTitle?.string == rhs.viewModel.title?.primaryTitle?.string &&
            lhs.viewModel.title?.secondaryTitle?.string == rhs.viewModel.title?.secondaryTitle?.string &&
            lhs.viewModel.primaryValue?.string == rhs.viewModel.primaryValue?.string &&
            lhs.viewModel.secondaryValue?.string == rhs.viewModel.secondaryValue?.string
    }
}

struct AccountAssetsCollectibleAssetListItem: Hashable {
    let asset: CollectibleAsset
    let viewModel: CollectibleListItemViewModel

    init(item: CollectibleAssetItem) {
        self.asset = item.asset
        self.viewModel = CollectibleListItemViewModel(item: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(asset.amount)
        hasher.combine(viewModel.primaryTitle?.string)
        hasher.combine(viewModel.secondaryTitle?.string)
    }

    static func == (
        lhs: AccountAssetsCollectibleAssetListItem,
        rhs: AccountAssetsCollectibleAssetListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.asset.amount == rhs.asset.amount &&
            lhs.viewModel.primaryTitle?.string == rhs.viewModel.primaryTitle?.string &&
            lhs.viewModel.secondaryTitle?.string == rhs.viewModel.secondaryTitle?.string
    }
}

struct AccountAssetsPendingCollectibleAssetListItem: Hashable {
    let viewModel: CollectibleListItemViewModel
    
    private let assetID: AssetID
    
    init(update: OptInBlockchainUpdate) {
        self.assetID = update.assetID
        self.viewModel = CollectibleListItemViewModel(update: update)
    }
    
    init(update: OptOutBlockchainUpdate) {
        self.assetID = update.assetID
        self.viewModel = CollectibleListItemViewModel(update: update)
    }
    
    init(update: SendPureCollectibleAssetBlockchainUpdate) {
        self.assetID = update.assetID
        self.viewModel = CollectibleListItemViewModel(update: update)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetID)
    }

    static func == (
        lhs: AccountAssetsPendingCollectibleAssetListItem,
        rhs: AccountAssetsPendingCollectibleAssetListItem
    ) -> Bool {
        return lhs.assetID == rhs.assetID
    }
}

struct AccountAssetsPendingAssetListItem: Hashable {
    let assetID: AssetID
    let viewModel: AssetListItemViewModel

    init(update: OptInBlockchainUpdate) {
       self.assetID = update.assetID
       self.viewModel = AssetListItemViewModel(update: update)
   }

    init(update: OptOutBlockchainUpdate) {
       self.assetID = update.assetID
       self.viewModel = AssetListItemViewModel(update: update)
   }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetID)
    }

    static func == (
        lhs: AccountAssetsPendingAssetListItem,
        rhs: AccountAssetsPendingAssetListItem
    ) -> Bool {
        return lhs.assetID == rhs.assetID
    }
}

enum AccountAssetListDataControllerEvent {
    case didUpdate(AccountAssetListUpdates)
}

struct AccountAssetListUpdates {
    let snapshot: Snapshot
    let operation: Operation
}

extension AccountAssetListUpdates {
    enum Operation {
        /// Load/Filter/Sort
        case customize
        /// Search by keyword
        case search
        /// Reload by the last query
        case refresh
    }
}

extension AccountAssetListUpdates {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountAssetsSection, AccountAssetsItem>
    typealias Completion = () -> Void
}
