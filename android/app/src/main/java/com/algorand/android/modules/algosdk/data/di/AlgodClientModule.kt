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

package com.algorand.android.modules.algosdk.data.di

import com.algorand.algosdk.v2.client.common.AlgodClient
import com.algorand.android.network.AlgodInterceptor
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ViewModelComponent
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull

@Module
@InstallIn(ViewModelComponent::class)
object AlgodClientModule {

    @Provides
    fun provideAlgodClient(
        algodInterceptor: AlgodInterceptor
    ): AlgodClient? {
        val currentNodeAlgodAddress = algodInterceptor.currentActiveNode?.algodAddress?.toHttpUrlOrNull() ?: return null
        return AlgodClient(
            currentNodeAlgodAddress.toString(),
            currentNodeAlgodAddress.port,
            algodInterceptor.currentActiveNode?.algodApiKey
        )
    }
}
