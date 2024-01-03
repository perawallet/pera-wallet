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

package com.algorand.android.modules.transaction.confirmation.data.di

import com.algorand.android.modules.algosdk.data.service.AlgorandSDKUtils
import com.algorand.android.modules.transaction.confirmation.data.mapper.TransactionConfirmationDTOMapper
import com.algorand.android.modules.transaction.confirmation.data.repository.TransactionConfirmationRepositoryImpl
import com.algorand.android.modules.transaction.confirmation.domain.repository.TransactionConfirmationRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ViewModelComponent
import javax.inject.Named

@Module
@InstallIn(ViewModelComponent::class)
object TransactionConfirmationRepositoryModule {

    @Provides
    @Named(TransactionConfirmationRepository.INJECTION_NAME)
    fun provideTransactionConfirmationRepository(
        @Named(AlgorandSDKUtils.INJECTION_NAME)
        algorandSDKUtils: AlgorandSDKUtils,
        transactionConfirmationDTOMapper: TransactionConfirmationDTOMapper
    ): TransactionConfirmationRepository {
        return TransactionConfirmationRepositoryImpl(algorandSDKUtils, transactionConfirmationDTOMapper)
    }
}
