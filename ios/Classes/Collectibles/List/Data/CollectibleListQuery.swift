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

//   CollectibleListQuery.swift

import Foundation

struct CollectibleListQuery: Equatable {
    var keyword: String?

    var showsWatchAccountNFTs: Bool = false

    /// <note>
    /// NFT amount > 0
    var showsOnlyOwnedNFTAssets: Bool = false

    var sortingAlgorithm: CollectibleSortingAlgorithm?

    init(
        filteringBy filters: CollectibleFilterOptions? = nil,
        sortingBy order: CollectibleSortingAlgorithm? = nil
    ) {
        update(withFilters: filters)
        update(withSort: order)
    }

    static func == (
        lhs: CollectibleListQuery,
        rhs: CollectibleListQuery
    ) -> Bool {
        return
            lhs.keyword == rhs.keyword &&
            lhs.showsWatchAccountNFTs == rhs.showsWatchAccountNFTs &&
            lhs.showsOnlyOwnedNFTAssets == rhs.showsOnlyOwnedNFTAssets &&
            lhs.sortingAlgorithm?.id == rhs.sortingAlgorithm?.id
    }
}

extension CollectibleListQuery {
    mutating func update(withFilters filters: CollectibleFilterOptions?) {
        showsWatchAccountNFTs = filters?.displayWatchAccountCollectibleAssetsInCollectibleList ?? true
        showsOnlyOwnedNFTAssets = !(filters?.displayOptedInCollectibleAssetsInCollectibleList ?? true)
    }

    mutating func update(withSort order: CollectibleSortingAlgorithm?) {
        sortingAlgorithm = order
    }
}

extension CollectibleListQuery {
    func matches(
        asset: CollectibleAsset,
        galleryAccount: CollectibleGalleryAccount,
        account: Account
    ) -> Bool {
        let matchesByKeyword = matchesByKeyword(asset)
        let matchesByFilters = matchesByFilters(
            asset: asset,
            galleryAccount: galleryAccount,
            account: account
        )
        return matchesByKeyword && matchesByFilters
    }

    func matchesByKeyword(_ asset: CollectibleAsset) -> Bool {
        guard let keyword = keyword.unwrapNonEmptyString() else {
            return true
        }

        let assetID = String(asset.id)
        if assetID.localizedCaseInsensitiveContains(keyword) {
            return true
        }

        let assetTitle = asset.title.someString
        if assetTitle.localizedCaseInsensitiveContains(keyword) {
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
        asset: CollectibleAsset,
        galleryAccount: CollectibleGalleryAccount,
        account: Account
    ) -> Bool {
        if !shouldDisplayWatchAccountCollectibleAsset(galleryAccount: galleryAccount, account: account) {
            return false
        }

        if !shouldDisplayOptedInCollectibleAsset(asset) {
            return false
        }

        return true
    }
}

extension CollectibleListQuery {
    private func shouldDisplayWatchAccountCollectibleAsset(galleryAccount: CollectibleGalleryAccount, account: Account) -> Bool {
        if !galleryAccount.isAll {
            return true
        }

        if !account.authorization.isWatch {
            return true
        }

        return showsWatchAccountNFTs
    }

    private func shouldDisplayOptedInCollectibleAsset(_ asset: CollectibleAsset) -> Bool {
        if asset.isOwned {
            return true
        }

        return !showsOnlyOwnedNFTAssets
    }
}
