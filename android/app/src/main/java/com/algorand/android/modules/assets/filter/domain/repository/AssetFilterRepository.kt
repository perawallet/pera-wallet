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

package com.algorand.android.modules.assets.filter.domain.repository

interface AssetFilterRepository {

    suspend fun getHideZeroBalanceAssetsPreference(defaultValue: Boolean): Boolean

    suspend fun saveHideZeroBalanceAssetsPreference(hideZeroBalanceAssets: Boolean)

    suspend fun getDisplayNFTInAssetsPreference(defaultValue: Boolean): Boolean

    suspend fun saveDisplayNFTInAssetsPreference(displayNFTInAssets: Boolean)

    suspend fun getDisplayOptedInNFTInAssetsPreference(defaultValue: Boolean): Boolean

    suspend fun saveDisplayOptedInNFTInAssetsPreference(displayOptedInNFTInAssets: Boolean)

    companion object {
        const val REPOSITORY_INJECTION_NAME = "AssetFilterRepositoryInjection"
    }
}
