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

package com.algorand.android.modules.assets.assetsort.ui.assetsortpreference.usecase

import com.algorand.android.modules.assets.assetsort.domain.model.BaseAssetSort
import com.algorand.android.modules.assets.assetsort.domain.model.BaseAssetSort.TypeIdentifier
import com.algorand.android.modules.assets.assetsort.domain.model.BaseAssetSort.TypeIdentifier.ALPHABETICALLY_ASCENDING
import com.algorand.android.modules.assets.assetsort.domain.model.BaseAssetSort.TypeIdentifier.ALPHABETICALLY_DESCENDING
import com.algorand.android.modules.assets.assetsort.domain.model.BaseAssetSort.TypeIdentifier.BALANCE_ASCENDING
import com.algorand.android.modules.assets.assetsort.domain.model.BaseAssetSort.TypeIdentifier.BALANCE_DESCENDING
import com.algorand.android.modules.assets.assetsort.domain.usecase.AssetSortUseCase
import com.algorand.android.modules.assets.assetsort.ui.assetsortpreference.mapper.AssetSortPreferencePreviewMapper
import com.algorand.android.modules.assets.assetsort.ui.assetsortpreference.model.AssetSortPreferencePreview
import javax.inject.Inject

class AssetSortPreferencePreviewUseCase @Inject constructor(
    private val assetSortPreferencePreviewMapper: AssetSortPreferencePreviewMapper,
    private val assetSortUseCase: AssetSortUseCase
) {

    fun getAssetSortPreferencePreview(): AssetSortPreferencePreview {
        val assetSortPreference = assetSortUseCase.getAssetSortPreference()
        return getAssetSortPreferencePreview(assetSortPreference)
    }

    fun saveAssetSortSelectedPreference(preview: AssetSortPreferencePreview) {
        val assetSortType = getCurrentlySelectedAssetSortPreference(preview)
        assetSortUseCase.saveAssetSortPreference(assetSortType)
    }

    fun getUpdatedPreviewForAlphabeticallyAscending(): AssetSortPreferencePreview {
        return getAssetSortPreferencePreview(ALPHABETICALLY_ASCENDING)
    }

    fun getUpdatedPreviewForAlphabeticallyDescending(): AssetSortPreferencePreview {
        return getAssetSortPreferencePreview(ALPHABETICALLY_DESCENDING)
    }

    fun getUpdatedPreviewForBalanceAscending(): AssetSortPreferencePreview {
        return getAssetSortPreferencePreview(BALANCE_ASCENDING)
    }

    fun getUpdatedPreviewForBalanceDescending(): AssetSortPreferencePreview {
        return getAssetSortPreferencePreview(BALANCE_DESCENDING)
    }

    private fun getAssetSortPreferencePreview(assetSortPreference: TypeIdentifier): AssetSortPreferencePreview {
        return assetSortPreferencePreviewMapper.mapToAssetSortPreferencePreview(
            isAlphabeticallyAscendingSelected = assetSortPreference.name == ALPHABETICALLY_ASCENDING.name,
            isAlphabeticallyDescendingSelected = assetSortPreference.name == ALPHABETICALLY_DESCENDING.name,
            isBalanceAscendingSelected = assetSortPreference.name == BALANCE_ASCENDING.name,
            isBalanceDescendingSelected = assetSortPreference.name == BALANCE_DESCENDING.name
        )
    }

    private fun getCurrentlySelectedAssetSortPreference(preview: AssetSortPreferencePreview): TypeIdentifier {
        return with(preview) {
            when {
                isAlphabeticallyAscendingSelected -> ALPHABETICALLY_ASCENDING
                isAlphabeticallyDescendingSelected -> ALPHABETICALLY_DESCENDING
                isBalanceAscendingSelected -> BALANCE_ASCENDING
                isBalanceDescendingSelected -> BALANCE_DESCENDING
                else -> BaseAssetSort.getDefaultSortOption().typeIdentifier
            }
        }
    }
}
