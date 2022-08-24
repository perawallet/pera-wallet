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

package com.algorand.android.modules.assets.assetsort.domain.usecase

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.assets.assetsort.domain.model.BaseAssetSort
import com.algorand.android.modules.assets.assetsort.domain.repository.AssetSortPreferencesRepository
import javax.inject.Inject
import javax.inject.Named

class AssetSortUseCase @Inject constructor(
    @Named(AssetSortPreferencesRepository.INJECTION_NAME)
    private val assetSortPreferencesRepository: AssetSortPreferencesRepository
) {

    fun sortAssets(assets: List<BaseAccountAssetData>): List<BaseAccountAssetData> {
        val assetSortPreference = assetSortPreferencesRepository.getAssetSortPreference()
        val assetSortType = BaseAssetSort.getSortTypeByIdentifier(assetSortPreference)
        return assetSortType.sort(assets)
    }

    fun saveAssetSortPreference(assetSortType: BaseAssetSort.TypeIdentifier) {
        assetSortPreferencesRepository.saveAssetSortPreference(assetSortType)
    }

    fun getAssetSortPreference(): BaseAssetSort.TypeIdentifier {
        return assetSortPreferencesRepository.getAssetSortPreference()
            ?: BaseAssetSort.getDefaultSortOption().typeIdentifier
    }
}
