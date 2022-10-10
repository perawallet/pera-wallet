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

package com.algorand.android.modules.sorting.assetsorting.data.repository

import com.algorand.android.modules.sorting.assetsorting.data.local.AssetSortPreferencesLocalSource
import com.algorand.android.modules.sorting.assetsorting.domain.model.AssetSortPreference
import com.algorand.android.modules.sorting.assetsorting.domain.repository.AssetSortPreferencesRepository
import javax.inject.Inject

class AssetSortPreferencesRepositoryImpl @Inject constructor(
    private val assetSortPreferencesLocalSource: AssetSortPreferencesLocalSource
) : AssetSortPreferencesRepository {

    override suspend fun saveAssetSortPreference(sortType: AssetSortPreference) {
        assetSortPreferencesLocalSource.saveData(sortType.name)
    }

    override suspend fun getAssetSortPreference(defaultValue: AssetSortPreference): AssetSortPreference {
        return AssetSortPreference.values().firstOrNull {
            it.name == assetSortPreferencesLocalSource.getDataOrNull()
        } ?: defaultValue
    }
}
