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

package com.algorand.android.modules.accountasset.data.di

import com.algorand.android.modules.accountasset.data.mapper.AccountAssetDetailMapper
import com.algorand.android.modules.accountasset.data.mapper.AssetDetailMapper
import com.algorand.android.modules.accountasset.data.repository.AccountAssetRepositoryImpl
import com.algorand.android.modules.accountasset.domain.repository.AccountAssetRepository
import com.algorand.android.network.AlgodApi
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
object AccountAssetRepositoryModule {

    @Provides
    fun provideAccountAssetRepository(
        algodApi: AlgodApi,
        accountAssetDetailMapper: AccountAssetDetailMapper,
        assetDetailMapper: AssetDetailMapper
    ): AccountAssetRepository {
        return AccountAssetRepositoryImpl(
            algodApi,
            accountAssetDetailMapper,
            assetDetailMapper
        )
    }
}
