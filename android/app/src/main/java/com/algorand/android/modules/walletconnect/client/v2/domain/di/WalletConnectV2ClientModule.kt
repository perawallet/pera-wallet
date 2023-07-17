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

package com.algorand.android.modules.walletconnect.client.v2.domain.di

import com.algorand.android.modules.walletconnect.client.v2.WalletConnectClientV2Impl
import com.algorand.android.modules.walletconnect.client.v2.domain.WalletConnectV2SignClient
import com.algorand.android.modules.walletconnect.client.v2.domain.repository.WalletConnectV2Repository
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.CacheWalletConnectV2PairUriUseCase
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.CreateWalletConnectSessionNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.RemoveAccountFromV2SessionUseCase
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectClientV2Mapper
import com.algorand.android.modules.walletconnect.client.v2.serverstatus.WalletConnectV2SessionServerStatusManager
import com.algorand.android.modules.walletconnect.client.v2.sessionexpiration.WalletConnectV2SessionExpirationManager
import com.algorand.android.modules.walletconnect.client.v2.utils.InitializeWalletConnectV2ClientUseCase
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectV2CaipUseCase
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectV2ErrorCodeProvider
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.WalletConnectV2ClientWalletDelegate
import com.algorand.android.modules.walletconnect.domain.WalletConnectClient
import com.algorand.android.modules.walletconnect.subscription.v2.domain.SubscribeWalletConnectV2SessionUseCase
import com.google.gson.Gson
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV2ClientModule {

    @Singleton
    @Provides
    @Named(WalletConnectClientV2Impl.INJECTION_NAME)
    @Suppress("LongParameterList")
    fun provideWalletConnectClient(
        clientV2Mapper: WalletConnectClientV2Mapper,
        errorCodeProvider: WalletConnectV2ErrorCodeProvider,
        createSessionNamespacesUseCase: CreateWalletConnectSessionNamespaceUseCase,
        @Named(WalletConnectV2Repository.INJECTION_NAME)
        walletConnectRepository: WalletConnectV2Repository,
        caipUseCase: WalletConnectV2CaipUseCase,
        initializeWalletConnectV2ClientUseCase: InitializeWalletConnectV2ClientUseCase,
        removeAccountFromV2SessionUseCase: RemoveAccountFromV2SessionUseCase,
        signClient: WalletConnectV2SignClient,
        walletDelegate: WalletConnectV2ClientWalletDelegate,
        cachePairUriUseCase: CacheWalletConnectV2PairUriUseCase,
        @Named(WalletConnectV2SessionExpirationManager.INJECTION_NAME)
        sessionExpirationManager: WalletConnectV2SessionExpirationManager,
        @Named(WalletConnectV2SessionServerStatusManager.INJECTION_NAME)
        sessionServerStatusManager: WalletConnectV2SessionServerStatusManager,
        gson: Gson
    ): WalletConnectClient {
        return WalletConnectClientV2Impl(
            clientV2Mapper = clientV2Mapper,
            errorCodeProvider = errorCodeProvider,
            createSessionNamespaceUseCase = createSessionNamespacesUseCase,
            walletConnectRepository = walletConnectRepository,
            caipUseCase = caipUseCase,
            initializeClientUseCase = initializeWalletConnectV2ClientUseCase,
            removeAccountFromSessionUseCase = removeAccountFromV2SessionUseCase,
            signClient = signClient,
            gson = gson,
            cachePairUriUseCase = cachePairUriUseCase,
            walletDelegate = walletDelegate,
            sessionExpirationManager = sessionExpirationManager,
            sessionServerStatusManager = sessionServerStatusManager
        )
    }

    @Provides
    @Named(SubscribeWalletConnectV2SessionUseCase.INJECTION_NAME)
    fun provideSubscribeWalletConnectSessionUseCase(): SubscribeWalletConnectV2SessionUseCase {
        return SubscribeWalletConnectV2SessionUseCase()
    }
}
