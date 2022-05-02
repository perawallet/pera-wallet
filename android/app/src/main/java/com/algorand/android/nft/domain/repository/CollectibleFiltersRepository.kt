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

package com.algorand.android.nft.domain.repository

interface CollectibleFiltersRepository {

    fun getOptedInNotOwnedCollectiblesPreference(defaultValue: Boolean): Boolean

    fun saveOptedInNotOwnedCollectiblePreference(showOptedInNotOwnedCollectibles: Boolean)

    companion object {
        const val COLLECTIBLE_FILTERS_REPOSITORY_INJECTION_NAME = "collectibleFiltersRepositoryInjection"
    }
}
