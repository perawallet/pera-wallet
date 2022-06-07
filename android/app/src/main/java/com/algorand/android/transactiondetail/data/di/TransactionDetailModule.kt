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

package com.algorand.android.transactiondetail.data.di

import com.algorand.android.network.IndexerApi
import com.algorand.android.transactiondetail.data.mapper.TransactionDetailDTOMapper
import com.algorand.android.transactiondetail.data.repository.TransactionDetailRepositoryImpl
import com.algorand.android.transactiondetail.domain.repository.TransactionDetailRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(ApplicationComponent::class)
object TransactionDetailModule {

    @Singleton
    @Provides
    @Named(TransactionDetailRepository.TRANSACTION_DETAIL_REPOSITORY_INJECTION_NAME)
    internal fun provideTransactionDetailRepository(
        indexerApi: IndexerApi,
        transactionDetailDTOMapper: TransactionDetailDTOMapper
    ): TransactionDetailRepository {
        return TransactionDetailRepositoryImpl(indexerApi, transactionDetailDTOMapper)
    }
}
