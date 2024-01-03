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

package com.algorand.android.modules.walletconnect.client.v1.retrycount.di

import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectV1SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v1.retrycount.WalletConnectV1SessionRetryCounter
import com.algorand.android.modules.walletconnect.client.v1.retrycount.WalletConnectV1SessionRetryCounterImpl
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectV1SessionCachedDataHandler
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectV1IdentifierParser
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV1SessionRetryModule {

    @Provides
    fun provideWalletConnectSessionRetryCounter(
        sessionCachedDataHandler: WalletConnectV1SessionCachedDataHandler,
        identifierParser: WalletConnectV1IdentifierParser,
        sessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper
    ): WalletConnectV1SessionRetryCounter {
        return WalletConnectV1SessionRetryCounterImpl(
            sessionCachedDataHandler = sessionCachedDataHandler,
            identifierParser = identifierParser,
            sessionIdentifierMapper = sessionIdentifierMapper
        )
    }
}
