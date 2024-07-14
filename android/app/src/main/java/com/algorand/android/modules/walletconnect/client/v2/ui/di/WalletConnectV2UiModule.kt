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

package com.algorand.android.modules.walletconnect.client.v2.ui.di

import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.connection.WCConnectionLaunchBackDescriptionAnnotatedStringProviderV2Impl
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.connection.WCConnectionLaunchBackSessionInformationAnnotatedStringProviderV2Impl
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.connection.WCConnectionLaunchBackTitleAnnotatedStringProviderV2Impl
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.transaction.WCArbitraryDataLaunchBackDescriptionAnnotatedStringProviderV2Impl
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.transaction.WCRequestLaunchBackDescriptionAnnotatedStringProviderV2Impl
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.usecase.GetFormattedWCSessionMaxExpirationDateUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackDescriptionAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackSessionInformationAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WcConnectionLaunchBackTitleAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.launchback.wcrequest.ui.model.WcRequestLaunchBackDescriptionAnnotatedStringProvider
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV2UiModule {

    @Provides
    @Named(WCConnectionLaunchBackDescriptionAnnotatedStringProviderV2Impl.INJECTION_NAME)
    fun provideWcConnectionLaunchBackDescriptionAnnotatedStringProvider():
            WCConnectionLaunchBackDescriptionAnnotatedStringProvider {
        return WCConnectionLaunchBackDescriptionAnnotatedStringProviderV2Impl()
    }

    @Provides
    @Named(WCConnectionLaunchBackSessionInformationAnnotatedStringProviderV2Impl.INJECTION_NAME)
    fun provideWcConnectionLaunchBackSessionInformationAnnotatedStringProvider():
        WCConnectionLaunchBackSessionInformationAnnotatedStringProvider {
        return WCConnectionLaunchBackSessionInformationAnnotatedStringProviderV2Impl()
    }

    @Provides
    @Named(WCConnectionLaunchBackTitleAnnotatedStringProviderV2Impl.INJECTION_NAME)
    fun provideWcConnectionLaunchBackTitleAnnotatedStringProvider():
        WcConnectionLaunchBackTitleAnnotatedStringProvider {
        return WCConnectionLaunchBackTitleAnnotatedStringProviderV2Impl()
    }

    @Provides
    @Named(WCRequestLaunchBackDescriptionAnnotatedStringProviderV2Impl.INJECTION_NAME)
    fun provideWcTransactionLaunchBackDescriptionAnnotatedStringProvider(
        getFormattedWCSessionMaxExpirationDateUseCase: GetFormattedWCSessionMaxExpirationDateUseCase,
        walletConnectManager: WalletConnectManager
    ): WcRequestLaunchBackDescriptionAnnotatedStringProvider {
        return WCRequestLaunchBackDescriptionAnnotatedStringProviderV2Impl(
            getFormattedWCSessionMaxExpirationDateUseCase,
            walletConnectManager
        )
    }

    @Provides
    @Named(WCArbitraryDataLaunchBackDescriptionAnnotatedStringProviderV2Impl.INJECTION_NAME)
    fun provideWcArbitraryDataLaunchBackDescriptionAnnotatedStringProvider(
        getFormattedWCSessionMaxExpirationDateUseCase: GetFormattedWCSessionMaxExpirationDateUseCase,
        walletConnectManager: WalletConnectManager
    ): WcRequestLaunchBackDescriptionAnnotatedStringProvider {
        return WCArbitraryDataLaunchBackDescriptionAnnotatedStringProviderV2Impl(
            getFormattedWCSessionMaxExpirationDateUseCase,
            walletConnectManager
        )
    }
}
