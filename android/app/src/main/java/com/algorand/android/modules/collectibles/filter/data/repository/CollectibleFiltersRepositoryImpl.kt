/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.modules.collectibles.filter.data.repository

import com.algorand.android.modules.collectibles.filter.data.local.CollectibleFilterNotOwnedLocalSource
import com.algorand.android.modules.collectibles.filter.data.local.CollectibleFilterNotOwnedLocalSource.Companion.FILTER_NOT_OWNED_COLLECTIBLES_DEFAULT_VALUE
import com.algorand.android.modules.collectibles.filter.data.local.NFTFilterDisplayWatchAccountNFTsLocalSource
import com.algorand.android.modules.collectibles.filter.data.local.NFTFilterDisplayWatchAccountNFTsLocalSource.Companion.NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_DEFAULT_PREFERENCES
import com.algorand.android.modules.collectibles.filter.domain.repository.CollectibleFiltersRepository

class CollectibleFiltersRepositoryImpl(
    private val collectibleFilterNotOwnedLocalSource: CollectibleFilterNotOwnedLocalSource,
    private val nftFilterDisplayWatchAccountNFTsLocalSource: NFTFilterDisplayWatchAccountNFTsLocalSource
) : CollectibleFiltersRepository {

    override suspend fun getOptedInNotOwnedCollectiblesPreference(): Boolean {
        return collectibleFilterNotOwnedLocalSource.getData(FILTER_NOT_OWNED_COLLECTIBLES_DEFAULT_VALUE)
    }

    override suspend fun saveOptedInNotOwnedCollectiblePreference(showOptedInNotOwnedCollectibles: Boolean) {
        collectibleFilterNotOwnedLocalSource.saveData(showOptedInNotOwnedCollectibles)
    }

    override suspend fun getDisplayWatchAccountNFTsPreference(): Boolean {
        return nftFilterDisplayWatchAccountNFTsLocalSource.getData(
            defaultValue = NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_DEFAULT_PREFERENCES
        )
    }

    override suspend fun saveDisplayWatchAccountNFTsPreference(showWatchAccountNFTsPreference: Boolean) {
        nftFilterDisplayWatchAccountNFTsLocalSource.saveData(showWatchAccountNFTsPreference)
    }

    override suspend fun clearCollectibleFiltersPreferences() {
        saveDisplayWatchAccountNFTsPreference(NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_DEFAULT_PREFERENCES)
        saveOptedInNotOwnedCollectiblePreference(FILTER_NOT_OWNED_COLLECTIBLES_DEFAULT_VALUE)
    }
}
