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

package com.algorand.android.modules.assets.filter.data.di

import com.algorand.android.modules.assets.filter.data.local.AssetFilterDisplayNFTLocalSource
import com.algorand.android.modules.assets.filter.data.local.AssetFilterDisplayOptedInNFTLocalSource
import com.algorand.android.modules.assets.filter.data.local.AssetFilterZeroBalanceLocalSource
import com.algorand.android.modules.assets.filter.data.repository.AssetFilterRepositoryImpl
import com.algorand.android.modules.assets.filter.domain.repository.AssetFilterRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AssetFilterModule {

    @Singleton
    @Provides
    @Named(AssetFilterRepository.REPOSITORY_INJECTION_NAME)
    fun provideAssetFilterRepository(
        assetFilterZeroBalanceLocalSource: AssetFilterZeroBalanceLocalSource,
        assetFilterDisplayNFTLocalSource: AssetFilterDisplayNFTLocalSource,
        assetFilterDisplayOptedInNFTLocalSource: AssetFilterDisplayOptedInNFTLocalSource
    ): AssetFilterRepository {
        return AssetFilterRepositoryImpl(
            assetFilterZeroBalanceLocalSource = assetFilterZeroBalanceLocalSource,
            assetFilterDisplayNFTLocalSource = assetFilterDisplayNFTLocalSource,
            assetFilterDisplayOptedInNFTLocalSource = assetFilterDisplayOptedInNFTLocalSource
        )
    }
}
