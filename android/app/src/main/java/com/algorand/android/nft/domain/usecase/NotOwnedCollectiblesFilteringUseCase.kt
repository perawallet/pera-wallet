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

package com.algorand.android.nft.domain.usecase

import com.algorand.android.models.AccountDetail
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.nft.domain.repository.CollectibleFiltersRepository
import com.algorand.android.nft.utils.CollectibleUtils
import javax.inject.Inject
import javax.inject.Named

class NotOwnedCollectiblesFilteringUseCase @Inject constructor(
    @Named(CollectibleFiltersRepository.COLLECTIBLE_FILTERS_REPOSITORY_INJECTION_NAME)
    private val collectibleFiltersRepository: CollectibleFiltersRepository,
    private val collectibleUtils: CollectibleUtils
) {

    fun shouldFilterOutCollectible(collectibleData: BaseAccountAssetData, accountDetail: AccountDetail): Boolean {
        val isFilterOutNotOwnedCollectiblesSelected = !getShowNotOwnedCollectiblesPreference()
        return if (isFilterOutNotOwnedCollectiblesSelected) {
            !collectibleUtils.isCollectibleOwnedByTheUser(accountDetail, collectibleData.id)
        } else {
            false
        }
    }

    fun getShowNotOwnedCollectiblesPreference(): Boolean {
        return collectibleFiltersRepository.getOptedInNotOwnedCollectiblesPreference(
            FILTER_NOT_OWNED_COLLECTIBLES_DEFAULT_VALUE
        )
    }

    fun saveFilterNotOwnedCollectiblesPreference(showNotOwnedCollectibles: Boolean) {
        collectibleFiltersRepository.saveOptedInNotOwnedCollectiblePreference(showNotOwnedCollectibles)
    }

    fun setFilterNotOwnedCollectiblesPreferenceAsDefault() {
        collectibleFiltersRepository.saveOptedInNotOwnedCollectiblePreference(
            FILTER_NOT_OWNED_COLLECTIBLES_DEFAULT_VALUE
        )
    }

    fun isFilterActive() = getShowNotOwnedCollectiblesPreference() != FILTER_NOT_OWNED_COLLECTIBLES_DEFAULT_VALUE

    companion object {
        private const val FILTER_NOT_OWNED_COLLECTIBLES_DEFAULT_VALUE = false
    }
}
