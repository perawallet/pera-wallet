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

package com.algorand.android.modules.sorting.assetsorting.ui.usecase

import com.algorand.android.modules.sorting.assetsorting.domain.model.AssetSortPreference
import com.algorand.android.modules.sorting.assetsorting.domain.usecase.AssetSortTypeUseCase
import com.algorand.android.modules.sorting.assetsorting.ui.model.AssetSortableItem
import javax.inject.Inject

class AssetItemSortUseCase @Inject constructor(
    private val assetSortTypeUseCase: AssetSortTypeUseCase
) {
    suspend fun <T : AssetSortableItem> sortAssets(assets: List<T>): List<T> {
        var sortedList = assets
        val alphabeticalSortComparator =
            compareBy<AssetSortableItem, String?>(nullsLast()) { it.assetSortingNameField?.uppercase() }

        val preferenceComparator = when (assetSortTypeUseCase.getSortPreferenceType()) {
            AssetSortPreference.ALPHABETICALLY_ASCENDING -> {
                alphabeticalSortComparator
            }
            AssetSortPreference.ALPHABETICALLY_DESCENDING -> {
                compareBy(nullsLast(reverseOrder())) { it.assetSortingNameField?.uppercase() }
            }
            AssetSortPreference.BALANCE_ASCENDING -> {
                sortedList = assets.sortedWith(alphabeticalSortComparator)
                compareBy(nullsLast()) { it.assetSortingBalanceField }
            }
            AssetSortPreference.BALANCE_DESCENDING -> {
                sortedList = assets.sortedWith(alphabeticalSortComparator)
                compareBy(nullsLast(reverseOrder())) { it.assetSortingBalanceField }
            }
        }
        val sortableItemPriorityComparator = compareBy<AssetSortableItem, Int>(nullsLast()) {
            it.sortableItemPriority.value
        }
        return sortedList
            .sortedWith(preferenceComparator)
            .sortedWith(sortableItemPriorityComparator)
    }
}
