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
import com.algorand.android.modules.sorting.nftsorting.domain.usecase.CollectibleSortTypeUseCase
import com.algorand.android.modules.sorting.nftsorting.ui.model.CollectibleSortableItem
import javax.inject.Inject

class CollectibleItemSortUseCase @Inject constructor(
    private val collectibleSortTypeUseCase: CollectibleSortTypeUseCase
) {
    suspend fun <T> sortCollectibles(collectibles: List<T>): List<T> where T : CollectibleSortableItem {
        val preferenceComparator = when (collectibleSortTypeUseCase.getSortPreferenceType()) {
            CollectibleSortPreference.ALPHABETICALLY_ASCENDING -> {
                compareBy<CollectibleSortableItem, String?>(nullsLast()) { it.collectibleSortingNameField?.uppercase() }
            }
            CollectibleSortPreference.ALPHABETICALLY_DESCENDING -> {
                compareBy(nullsLast(reverseOrder())) { it.collectibleSortingNameField?.uppercase() }
            }
            CollectibleSortPreference.NEWEST_TO_OLDEST -> {
                compareBy(nullsLast(reverseOrder())) { it.collectibleSortingOptedInAtRoundField }
            }
            CollectibleSortPreference.OLDEST_TO_NEWEST -> {
                compareBy(nullsLast()) { it.collectibleSortingOptedInAtRoundField }
            }
        }
        val sortableItemPriorityComparator = compareBy<CollectibleSortableItem, Int>(nullsLast()) {
            it.sortableItemPriority.value
        }
        return collectibles
            .sortedWith(preferenceComparator)
            .sortedWith(sortableItemPriorityComparator)
    }
}
