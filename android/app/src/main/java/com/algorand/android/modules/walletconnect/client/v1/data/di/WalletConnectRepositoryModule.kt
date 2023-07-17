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

package com.algorand.android.modules.walletconnect.client.v1.data.di

import com.algorand.android.database.WalletConnectDao
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionAccountDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionByAccountsAddressDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionWithAccountsAddressesDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectSessionAccountEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectSessionEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.data.repository.WalletConnectV1RepositoryImpl
import com.algorand.android.modules.walletconnect.client.v1.domain.repository.WalletConnectRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectRepositoryModule {

    @Provides
    @Singleton
    @Named(WalletConnectRepository.INJECTION_NAME)
    fun provideWalletConnectRepository(
        walletConnectDao: WalletConnectDao,
        sessionAccountDtoMapper: WalletConnectSessionAccountDtoMapper,
        sessionAccountEntityMapper: WalletConnectSessionAccountEntityMapper,
        sessionDtoMapper: WalletConnectSessionDtoMapper,
        sessionEntityMapper: WalletConnectSessionEntityMapper,
        sessionByAccountsAddressDtoMapper: WalletConnectSessionByAccountsAddressDtoMapper,
        sessionWithAccountsAddressesDtoMapper: WalletConnectSessionWithAccountsAddressesDtoMapper
    ): WalletConnectRepository {
        return WalletConnectV1RepositoryImpl(
            walletConnectDao = walletConnectDao,
            sessionAccountDtoMapper = sessionAccountDtoMapper,
            sessionAccountEntityMapper = sessionAccountEntityMapper,
            sessionDtoMapper = sessionDtoMapper,
            sessionEntityMapper = sessionEntityMapper,
            sessionByAccountsAddressDtoMapper = sessionByAccountsAddressDtoMapper,
            sessionWithAccountsAddressesDtoMapper = sessionWithAccountsAddressesDtoMapper
        )
    }
}
