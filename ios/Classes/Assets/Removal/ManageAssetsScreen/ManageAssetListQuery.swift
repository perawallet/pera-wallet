// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ManageAssetListQuery.swift

import Foundation

struct ManageAssetListQuery: Equatable {
    var keyword: String?
    
    var sortingAlgorithm: AccountAssetSortingAlgorithm?
    
    init(
        sortingBy order: AccountAssetSortingAlgorithm? = nil
    ) {
        sortingAlgorithm = order
    }
    
    static func == (
        lhs: ManageAssetListQuery,
        rhs: ManageAssetListQuery
    ) -> Bool {
        return
            lhs.keyword == rhs.keyword &&
            lhs.sortingAlgorithm?.id == rhs.sortingAlgorithm?.id
    }
}

extension ManageAssetListQuery {
    func matches(
        asset: Asset,
        account: Account
    ) -> Bool {
        let matchesByKeyword = matchesByKeyword(asset)
        let matchesByFilters = matchesByFilters(
            asset: asset,
            account: account
        )
        return matchesByKeyword && matchesByFilters
    }
    
    private func matchesByKeyword(_ asset: Asset) -> Bool {
        guard let keyword = keyword.unwrapNonEmptyString() else {
            return true
        }
        
        let assetID = String(asset.id)
        if assetID.localizedCaseInsensitiveContains(keyword) {
            return true
        }
        
        let assetName = asset.naming.name.someString
        if assetName.localizedCaseInsensitiveContains(keyword) {
            return true
        }
        
        let assetUnitName = asset.naming.unitName.someString
        if assetUnitName.localizedCaseInsensitiveContains(keyword) {
            return true
        }
        
        return false
    }
    
    private func matchesByFilters(
        asset: Asset,
        account: Account
    ) -> Bool {
        return shouldDisplayAssetCreatedByAccount(
            asset: asset,
            account: account
        )
    }
    
    private func shouldDisplayAssetCreatedByAccount(
        asset: Asset,
        account: Account
    ) -> Bool {
        return !account.isCreator(of: asset)
    }
}
