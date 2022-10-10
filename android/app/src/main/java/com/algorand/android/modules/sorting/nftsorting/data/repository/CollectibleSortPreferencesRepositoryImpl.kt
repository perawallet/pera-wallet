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

package com.algorand.android.modules.sorting.nftsorting.data.repository

import com.algorand.android.modules.sorting.nftsorting.data.local.CollectibleSortPreferencesLocalSource
import com.algorand.android.modules.sorting.nftsorting.domain.model.CollectibleSortPreference
import com.algorand.android.modules.sorting.nftsorting.domain.repository.CollectibleSortPreferencesRepository
import javax.inject.Inject

class CollectibleSortPreferencesRepositoryImpl @Inject constructor(
    private val collectibleSortPreferencesLocalSource: CollectibleSortPreferencesLocalSource
) : CollectibleSortPreferencesRepository {

    override suspend fun saveCollectibleSortPreference(sortType: CollectibleSortPreference) {
        collectibleSortPreferencesLocalSource.saveData(sortType.name)
    }

    override suspend fun getCollectibleSortPreference(
        defaultValue: CollectibleSortPreference
    ): CollectibleSortPreference {
        return CollectibleSortPreference.values().firstOrNull {
            it.name == collectibleSortPreferencesLocalSource.getDataOrNull()
        } ?: defaultValue
    }
}
