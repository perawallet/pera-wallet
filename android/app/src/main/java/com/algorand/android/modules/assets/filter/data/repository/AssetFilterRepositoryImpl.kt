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

package com.algorand.android.modules.assets.filter.data.repository

import com.algorand.android.modules.assets.filter.data.local.AssetFilterDisplayNFTLocalSource
import com.algorand.android.modules.assets.filter.data.local.AssetFilterDisplayOptedInNFTLocalSource
import com.algorand.android.modules.assets.filter.data.local.AssetFilterZeroBalanceLocalSource
import com.algorand.android.modules.assets.filter.domain.repository.AssetFilterRepository

class AssetFilterRepositoryImpl(
    private val assetFilterZeroBalanceLocalSource: AssetFilterZeroBalanceLocalSource,
    private val assetFilterDisplayNFTLocalSource: AssetFilterDisplayNFTLocalSource,
    private val assetFilterDisplayOptedInNFTLocalSource: AssetFilterDisplayOptedInNFTLocalSource
) : AssetFilterRepository {

    override suspend fun getHideZeroBalanceAssetsPreference(defaultValue: Boolean): Boolean {
        return assetFilterZeroBalanceLocalSource.getData(defaultValue)
    }

    override suspend fun saveHideZeroBalanceAssetsPreference(hideZeroBalanceAssets: Boolean) {
        assetFilterZeroBalanceLocalSource.saveData(hideZeroBalanceAssets)
    }

    override suspend fun getDisplayNFTInAssetsPreference(defaultValue: Boolean): Boolean {
        return assetFilterDisplayNFTLocalSource.getData(defaultValue)
    }

    override suspend fun saveDisplayNFTInAssetsPreference(displayNFTInAssets: Boolean) {
        assetFilterDisplayNFTLocalSource.saveData(displayNFTInAssets)
    }

    override suspend fun getDisplayOptedInNFTInAssetsPreference(defaultValue: Boolean): Boolean {
        return assetFilterDisplayOptedInNFTLocalSource.getData(defaultValue)
    }

    override suspend fun saveDisplayOptedInNFTInAssetsPreference(displayOptedInNFTInAssets: Boolean) {
        assetFilterDisplayOptedInNFTLocalSource.saveData(displayOptedInNFTInAssets)
    }
}
