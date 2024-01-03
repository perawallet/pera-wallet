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

package com.algorand.android.nft.ui.nftfilters.usecase

import com.algorand.android.modules.collectibles.filter.domain.usecase.SaveDisplayOptedInNFTPreferenceUseCase
import com.algorand.android.modules.collectibles.filter.domain.usecase.SaveDisplayWatchAccountNFTsPreferenceUseCase
import com.algorand.android.modules.collectibles.filter.domain.usecase.ShouldDisplayOptedInNFTPreferenceUseCase
import com.algorand.android.modules.collectibles.filter.domain.usecase.ShouldDisplayWatchAccountNFTsPreferenceUseCase
import com.algorand.android.nft.ui.nftfilters.mapper.CollectibleFiltersPreviewMapper
import com.algorand.android.nft.ui.nftfilters.model.CollectibleFiltersPreview
import javax.inject.Inject

class CollectibleFiltersPreviewUseCase @Inject constructor(
    private val collectibleFiltersPreviewMapper: CollectibleFiltersPreviewMapper,
    private val saveDisplayOptedInNFTPreferenceUseCase: SaveDisplayOptedInNFTPreferenceUseCase,
    private val shouldDisplayOptedInNFTPreferenceUseCase: ShouldDisplayOptedInNFTPreferenceUseCase,
    private val saveDisplayWatchAccountNFTsPreferenceUseCase: SaveDisplayWatchAccountNFTsPreferenceUseCase,
    private val shouldDisplayWatchAccountNFTsPreferenceUseCase: ShouldDisplayWatchAccountNFTsPreferenceUseCase
) {

    suspend fun getCollectibleFiltersPreviewFlow(): CollectibleFiltersPreview {
        val displayOptedInNFTsPreference = shouldDisplayOptedInNFTPreferenceUseCase()
        val displayWatchAccountNFTsPreference = shouldDisplayWatchAccountNFTsPreferenceUseCase()
        return collectibleFiltersPreviewMapper.mapToCollectibleFiltersPreview(
            displayOptedInNFTsPreference = displayOptedInNFTsPreference,
            displayWatchAccountNFTsPreference = displayWatchAccountNFTsPreference
        )
    }

    suspend fun saveDisplayOptedInNFTsPreference(displayOptedInNFTsPreference: Boolean) {
        saveDisplayOptedInNFTPreferenceUseCase.invoke(displayOptedInNFTsPreference)
    }

    suspend fun saveDisplayWatchAccountNFTsPreference(showWatchAccountNFTsPreferences: Boolean) {
        saveDisplayWatchAccountNFTsPreferenceUseCase.invoke(showWatchAccountNFTsPreferences)
    }
}
