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
import com.algorand.android.modules.algosdk.data.mapper.AlgorandAddressDTOMapper
import com.algorand.android.modules.algosdk.data.mapper.PendingTransactionResponseDTOMapper
import com.algorand.android.modules.algosdk.data.mapper.rawtransaction.RawTransactionDTOMapper
import com.algorand.android.modules.algosdk.data.repository.AlgorandSDKUtilsImpl
import com.algorand.android.modules.algosdk.data.service.AlgorandSDKUtils
import com.google.gson.Gson
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ViewModelComponent
import javax.inject.Named

@Module
@InstallIn(ViewModelComponent::class)
object AlgorandSDKUtilsModule {

    @Provides
    @Named(AlgorandSDKUtils.INJECTION_NAME)
    fun provideAlgorandSDKUtils(
        pendingTransactionResponseDTOMapper: PendingTransactionResponseDTOMapper,
        algodClient: AlgodClient?,
        rawTransactionDTOMapper: RawTransactionDTOMapper,
        algorandAddressDTOMapper: AlgorandAddressDTOMapper,
        gson: Gson
    ): AlgorandSDKUtils {
        return AlgorandSDKUtilsImpl(
            pendingTransactionResponseDTOMapper = pendingTransactionResponseDTOMapper,
            rawTransactionDTOMapper = rawTransactionDTOMapper,
            algorandAddressDTOMapper = algorandAddressDTOMapper,
            algodClient = algodClient,
            gson = gson
        )
    }
}
