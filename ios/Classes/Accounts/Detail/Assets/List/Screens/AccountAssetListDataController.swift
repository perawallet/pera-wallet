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

    func load()
    func reload()
    func reloadIfThereIsPendingUpdates()
}

enum AccountAssetsSection:
    Int,
    Hashable {
    case portfolio
    case quickActions
    case assets
    case empty
}

enum AccountAssetsItem: Hashable {
    case portfolio(AccountPortfolioViewModel)
    case watchPortfolio(AccountPortfolioViewModel)
    case search
    case asset(AssetListItemViewModel)
    case pendingAsset(PendingAssetPreviewViewModel)
    case assetManagement(ManagementItemViewModel)
    case watchAccountAssetManagement(ManagementItemViewModel)
    case quickActions
    case empty(AssetListSearchNoContentViewModel)
}

enum AccountAssetListDataControllerEvent {
    case didUpdate(AccountAssetListUpdates)
}

struct AccountAssetListUpdates {
    var isNewSearch = false
    var completion: Completion?

    let snapshot: Snapshot

    init(snapshot: Snapshot) {
        self.snapshot = snapshot
    }
}

extension AccountAssetListUpdates {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountAssetsSection, AccountAssetsItem>
    typealias Completion = () -> Void
}
