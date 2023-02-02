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

// AccountAssetListQuery.swift

import Foundation

struct AccountAssetListQuery: Equatable {
    var keyword: String?

    var showsOnlyNonNFTAssets: Bool = false
    /// <note>
    /// Non-NFT amount > 0
    var showsOnlyOwnedNonNFTAssets: Bool = false
    /// <note>
    /// NFT amount > 0
    var showsOnlyOwnedNFTAssets: Bool = false

    var sortingAlgorithm: AccountAssetSortingAlgorithm?

    init(
        filteringBy filters: AssetFilterOptions? = nil,
        sortingBy order: AccountAssetSortingAlgorithm? = nil
    ) {
        update(withFilters: filters)
        update(withSort: order)
    }

    static func == (
        lhs: AccountAssetListQuery,
        rhs: AccountAssetListQuery
    ) -> Bool {
        return
            lhs.keyword == rhs.keyword &&
            lhs.showsOnlyNonNFTAssets == rhs.showsOnlyNonNFTAssets &&
            lhs.showsOnlyOwnedNonNFTAssets == rhs.showsOnlyOwnedNonNFTAssets &&
            lhs.showsOnlyOwnedNFTAssets == rhs.showsOnlyOwnedNFTAssets &&
            lhs.sortingAlgorithm?.id == rhs.sortingAlgorithm?.id
    }
}

extension AccountAssetListQuery {
    mutating func update(withFilters filters: AssetFilterOptions?) {
        showsOnlyNonNFTAssets = !(filters?.displayCollectibleAssetsInAssetList ?? true)
        showsOnlyOwnedNonNFTAssets = filters?.hideAssetsWithNoBalanceInAssetList ?? false
        showsOnlyOwnedNFTAssets = !(filters?.displayOptedInCollectibleAssetsInAssetList ?? true)
    }

    mutating func update(withSort order: AccountAssetSortingAlgorithm?) {
        sortingAlgorithm = order
    }
}

extension AccountAssetListQuery {
    func matches(_ asset: Asset) -> Bool {
        return matchesByKeyword(asset) && matchesByFilters(asset)
    }

    func matchesByKeyword(_ asset: Asset) -> Bool {
        guard let keyword = keyword.unwrapNonEmptyString() else {
            return true
        }

        if asset.isAlgo, "algo".containsCaseInsensitive(keyword) {
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

    func matchesByFilters(_ asset: Asset) -> Bool {
        switch asset {
        case let nonNFTAsset as StandardAsset: return matchesByFilters(nonNFT: nonNFTAsset)
        case let nftAsset as CollectibleAsset: return matchesByFilters(nft: nftAsset)
        default: return false
        }
    }

    private func matchesByFilters(nonNFT asset: StandardAsset) -> Bool {
        if !showsOnlyOwnedNonNFTAssets {
            return true
        }

        return asset.amount != .zero
    }

    private func matchesByFilters(nft asset: CollectibleAsset) -> Bool {
        if showsOnlyNonNFTAssets {
            return false
        }

        if !showsOnlyOwnedNFTAssets {
            return true
        }

        return asset.isOwned
    }
}
