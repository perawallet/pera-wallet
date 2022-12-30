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

package com.algorand.android.modules.assets.filter.ui.usecase

import com.algorand.android.modules.assets.filter.domain.usecase.SaveDisplayNFTInAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.domain.usecase.SaveDisplayOptedInNFTInAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.domain.usecase.SaveHideZeroBalanceAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.domain.usecase.ShouldDisplayNFTInAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.domain.usecase.ShouldDisplayOptedInNFTInAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.domain.usecase.ShouldHideZeroBalanceAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.ui.mapper.AssetFilterPreviewMapper
import com.algorand.android.modules.assets.filter.ui.model.AssetFilterPreview
import javax.inject.Inject

class AssetFilterPreviewUseCase @Inject constructor(
    private val shouldHideZeroBalanceAssetsPreferenceUseCase: ShouldHideZeroBalanceAssetsPreferenceUseCase,
    private val saveHideZeroBalanceAssetsPreferenceUseCase: SaveHideZeroBalanceAssetsPreferenceUseCase,
    private val shouldDisplayNFTInAssetsPreferenceUseCase: ShouldDisplayNFTInAssetsPreferenceUseCase,
    private val saveDisplayNFTInAssetsPreferenceUseCase: SaveDisplayNFTInAssetsPreferenceUseCase,
    private val shouldDisplayOptedInNFTInAssetsPreferenceUseCase: ShouldDisplayOptedInNFTInAssetsPreferenceUseCase,
    private val saveDisplayOptedInNFTInAssetsPreferenceUseCase: SaveDisplayOptedInNFTInAssetsPreferenceUseCase,
    private val assetFilterPreviewMapper: AssetFilterPreviewMapper
) {

    suspend fun getAssetFilterPreview(): AssetFilterPreview {
        val hideZeroBalanceAssetsPreference = shouldHideZeroBalanceAssetsPreferenceUseCase()
        val displayNFTINAssetPreference = shouldDisplayNFTInAssetsPreferenceUseCase()
        val displayOptedInNFTINAssetPreference = shouldDisplayOptedInNFTInAssetsPreferenceUseCase()
        return assetFilterPreviewMapper.mapToAssetFilterPreview(
            hideZeroBalanceAssets = hideZeroBalanceAssetsPreference,
            displayNFTInAssets = displayNFTINAssetPreference,
            displayOptedInNFTInAssets = displayOptedInNFTINAssetPreference,
            isDisplayOptedInNFTInAssetsOptionActive = displayNFTINAssetPreference && displayOptedInNFTINAssetPreference
        )
    }

    suspend fun saveFilterZeroBalanceAssetPreference(shouldHideZeroBalanceAssets: Boolean) {
        saveHideZeroBalanceAssetsPreferenceUseCase(shouldHideZeroBalanceAssets)
    }

    suspend fun saveDisplayNFTInAssetsPreference(displayNFTInAssets: Boolean) {
        saveDisplayNFTInAssetsPreferenceUseCase.invoke(displayNFTInAssets)
    }

    suspend fun saveDisplayOptedInNFTInAssetsPreference(displayOptedInNFTInAssets: Boolean) {
        saveDisplayOptedInNFTInAssetsPreferenceUseCase.invoke(displayOptedInNFTInAssets)
    }
}
