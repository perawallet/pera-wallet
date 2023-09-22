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

package com.algorand.android.modules.walletconnect.client.v1.domain.di

import android.content.Context
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.deviceregistration.domain.usecase.FirebasePushTokenUseCase
import com.algorand.android.modules.walletconnect.client.v1.WalletConnectClientV1Impl
import com.algorand.android.modules.walletconnect.client.v1.domain.decider.WalletConnectV1ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v1.domain.repository.WalletConnectRepository
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.CreateWalletConnectProposalNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.CreateWalletConnectSessionNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.DeleteWalletConnectAccountBySessionUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetConnectedAccountsOfWalletConnectSessionUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetDisconnectedWalletConnectSessionsUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetWalletConnectSessionsByAccountAddressUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetWalletConnectSessionsOrderedByCreationUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetWalletConnectV1SessionCountUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.InsertWalletConnectV1SessionToDBUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.WalletConnectV1SessionRequestIdValidationUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.WalletConnectV1TransactionRequestIdValidationUseCase
import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectClientV1Mapper
import com.algorand.android.modules.walletconnect.client.v1.retrycount.WalletConnectV1SessionRetryCounter
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectSessionBuilder
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectV1SessionCachedDataHandler
import com.algorand.android.modules.walletconnect.client.v1.session.mapper.WalletConnectSessionConfigMapper
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectV1ErrorCodeProvider
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectV1IdentifierParser
import com.algorand.android.modules.walletconnect.domain.WalletConnectClient
import com.algorand.android.modules.walletconnect.subscription.data.mapper.WalletConnectSessionSubscriptionBodyMapper
import com.algorand.android.modules.walletconnect.subscription.data.usecase.SetGivenSessionAsSubscribedUseCase
import com.algorand.android.modules.walletconnect.subscription.domain.SubscribeWalletConnectSessionUseCase
import com.algorand.android.modules.walletconnect.subscription.v1.domain.SubscribeWalletConnectV1SessionUseCase
import com.algorand.android.network.MobileAlgorandApi
import com.google.gson.Gson
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import org.walletconnect.impls.FileWCSessionStore
import java.io.File
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV1ClientModule {

    @Singleton
    @Provides
    @Named(WalletConnectClientV1Impl.INJECTION_NAME)
    @Suppress("LongParameterList")
    fun provideWalletConnectClient(
        sessionBuilder: WalletConnectSessionBuilder,
        walletConnectMapper: WalletConnectClientV1Mapper,
        errorCodeProvider: WalletConnectV1ErrorCodeProvider,
        sessionCachedDataHandler: WalletConnectV1SessionCachedDataHandler,
        @Named(WalletConnectRepository.INJECTION_NAME)
        walletConnectRepository: WalletConnectRepository,
        getConnectedAccountsOfWalletConnectSessionUseCase: GetConnectedAccountsOfWalletConnectSessionUseCase,
        getWalletConnectSessionsByAccountAddressUseCase: GetWalletConnectSessionsByAccountAddressUseCase,
        insertWalletConnectV1SessionToDBUseCase: InsertWalletConnectV1SessionToDBUseCase,
        identifierParser: WalletConnectV1IdentifierParser,
        getDisconnectedWalletConnectSessionsUseCase: GetDisconnectedWalletConnectSessionsUseCase,
        createWalletConnectSessionNamespaceUseCase: CreateWalletConnectSessionNamespaceUseCase,
        chainIdentifierDecider: WalletConnectV1ChainIdentifierDecider,
        createWalletConnectProposalNamespaceUseCase: CreateWalletConnectProposalNamespaceUseCase,
        deleteWalletConnectAccountBySessionUseCase: DeleteWalletConnectAccountBySessionUseCase,
        getWalletConnectSessionsOrderedByCreationUseCase: GetWalletConnectSessionsOrderedByCreationUseCase,
        getWalletConnectV1SessionCountUseCase: GetWalletConnectV1SessionCountUseCase,
        walletConnectV1SessionRetryCounter: WalletConnectV1SessionRetryCounter,
        sessionRequestIdValidationUseCase: WalletConnectV1SessionRequestIdValidationUseCase,
        transactionRequestIdValidationUseCase: WalletConnectV1TransactionRequestIdValidationUseCase
    ): WalletConnectClient {
        return WalletConnectClientV1Impl(
            sessionBuilder = sessionBuilder,
            walletConnectMapper = walletConnectMapper,
            errorCodeProvider = errorCodeProvider,
            sessionCachedDataHandler = sessionCachedDataHandler,
            walletConnectRepository = walletConnectRepository,
            getConnectedAccountsOfWalletConnectSessionUseCase = getConnectedAccountsOfWalletConnectSessionUseCase,
            getWalletConnectSessionsByAccountAddressUseCase = getWalletConnectSessionsByAccountAddressUseCase,
            insertWalletConnectV1SessionToDBUseCase = insertWalletConnectV1SessionToDBUseCase,
            identifierParser = identifierParser,
            getDisconnectedWalletConnectSessionsUseCase = getDisconnectedWalletConnectSessionsUseCase,
            createWalletConnectSessionNamespaceUseCase = createWalletConnectSessionNamespaceUseCase,
            chainIdentifierDecider = chainIdentifierDecider,
            createWalletConnectProposalNamespaceUseCase = createWalletConnectProposalNamespaceUseCase,
            deleteWalletConnectAccountBySessionUseCase = deleteWalletConnectAccountBySessionUseCase,
            getWalletConnectSessionsOrderedByCreationUseCase = getWalletConnectSessionsOrderedByCreationUseCase,
            getWalletConnectV1SessionCountUseCase = getWalletConnectV1SessionCountUseCase,
            walletConnectSessionRetryCounter = walletConnectV1SessionRetryCounter,
            sessionRequestIdValidationUseCase = sessionRequestIdValidationUseCase,
            transactionRequestIdValidationUseCase = transactionRequestIdValidationUseCase
        )
    }

    @Singleton
    @Provides
    fun provideWalletConnectSessionBuilder(
        @Named("walletConnectHttpClient") okHttpClient: OkHttpClient,
        @ApplicationContext appContext: Context,
        gson: Gson,
        moshi: Moshi,
        walletConnectMapper: WalletConnectSessionConfigMapper
    ): WalletConnectSessionBuilder {
        val storageFile = File(appContext.cacheDir, WalletConnectClientV1Impl.CACHE_STORAGE_NAME).apply {
            createNewFile()
        }
        return WalletConnectSessionBuilder(
            gson,
            moshi,
            okHttpClient,
            FileWCSessionStore(storageFile, moshi),
            walletConnectMapper
        )
    }

    @Singleton
    @Provides
    fun provideMoshi(): Moshi {
        return Moshi.Builder()
            .addLast(KotlinJsonAdapterFactory())
            .build()
    }

    @Singleton
    @Provides
    @Named(SubscribeWalletConnectV1SessionUseCase.INJECTION_NAME)
    fun provideSubscribeWalletConnectSessionUseCase(
        firebasePushTokenUseCase: FirebasePushTokenUseCase,
        mobileAlgorandApi: MobileAlgorandApi,
        deviceIdUseCase: DeviceIdUseCase,
        setGivenSessionAsSubscribedUseCase: SetGivenSessionAsSubscribedUseCase,
        walletConnectSessionSubscriptionBodyMapper: WalletConnectSessionSubscriptionBodyMapper
    ): SubscribeWalletConnectSessionUseCase {
        return SubscribeWalletConnectV1SessionUseCase(
            firebasePushTokenUseCase,
            mobileAlgorandApi,
            deviceIdUseCase,
            setGivenSessionAsSubscribedUseCase,
            walletConnectSessionSubscriptionBodyMapper
        )
    }
}
