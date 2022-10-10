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

package com.algorand.android.modules.sorting.nftsorting.ui.usecase

import com.algorand.android.modules.sorting.nftsorting.domain.model.CollectibleSortPreference
import com.algorand.android.modules.sorting.nftsorting.domain.model.CollectibleSortPreference.ALPHABETICALLY_ASCENDING
import com.algorand.android.modules.sorting.nftsorting.domain.model.CollectibleSortPreference.ALPHABETICALLY_DESCENDING
import com.algorand.android.modules.sorting.nftsorting.domain.model.CollectibleSortPreference.NEWEST_TO_OLDEST
import com.algorand.android.modules.sorting.nftsorting.domain.model.CollectibleSortPreference.OLDEST_TO_NEWEST
import com.algorand.android.modules.sorting.nftsorting.domain.usecase.CollectibleSortTypeUseCase
import com.algorand.android.modules.sorting.nftsorting.ui.mapper.CollectibleSortPreferencePreviewMapper
import com.algorand.android.modules.sorting.nftsorting.ui.model.CollectibleSortPreferencePreview
import javax.inject.Inject

class CollectibleSortPreferencePreviewUseCase @Inject constructor(
    private val collectibleSortPreferencePreviewMapper: CollectibleSortPreferencePreviewMapper,
    private val collectibleSortTypeUseCase: CollectibleSortTypeUseCase
) {

    suspend fun getCollectibleSortPreferencePreview(): CollectibleSortPreferencePreview {
        val collectibleSortPreference = collectibleSortTypeUseCase.getSortPreferenceType()
        return getCollectibleSortPreferencePreview(collectibleSortPreference)
    }

    suspend fun saveCollectibleSortSelectedPreference(preview: CollectibleSortPreferencePreview) {
        val collectibleSortPreference = getCurrentlySelectedCollectibleSortPreference(preview)
        collectibleSortTypeUseCase.saveSortPreferenceType(collectibleSortPreference)
    }

    fun getUpdatedPreviewForAlphabeticallyAscending(): CollectibleSortPreferencePreview {
        return getCollectibleSortPreferencePreview(ALPHABETICALLY_ASCENDING)
    }

    fun getUpdatedPreviewForAlphabeticallyDescending(): CollectibleSortPreferencePreview {
        return getCollectibleSortPreferencePreview(ALPHABETICALLY_DESCENDING)
    }

    fun getUpdatedPreviewForNewestToOldest(): CollectibleSortPreferencePreview {
        return getCollectibleSortPreferencePreview(NEWEST_TO_OLDEST)
    }

    fun getUpdatedPreviewForOldestToNewest(): CollectibleSortPreferencePreview {
        return getCollectibleSortPreferencePreview(OLDEST_TO_NEWEST)
    }

    private fun getCollectibleSortPreferencePreview(
        collectibleSortPreference: CollectibleSortPreference
    ): CollectibleSortPreferencePreview {
        return collectibleSortPreferencePreviewMapper.mapToCollectibleSortPreferencePreview(
            isAlphabeticallyAscendingSelected = collectibleSortPreference.name == ALPHABETICALLY_ASCENDING.name,
            isAlphabeticallyDescendingSelected = collectibleSortPreference.name == ALPHABETICALLY_DESCENDING.name,
            isNewestToOldestSelected = collectibleSortPreference.name == NEWEST_TO_OLDEST.name,
            isOldestToNewestSelected = collectibleSortPreference.name == OLDEST_TO_NEWEST.name
        )
    }

    private fun getCurrentlySelectedCollectibleSortPreference(
        preview: CollectibleSortPreferencePreview
    ): CollectibleSortPreference {
        return with(preview) {
            when {
                isAlphabeticallyAscendingSelected -> ALPHABETICALLY_ASCENDING
                isAlphabeticallyDescendingSelected -> ALPHABETICALLY_DESCENDING
                isOldestToNewestSelected -> OLDEST_TO_NEWEST
                isNewestToOldestSelected -> NEWEST_TO_OLDEST
                else -> CollectibleSortPreference.getDefaultSortPreference()
            }
        }
    }
}
