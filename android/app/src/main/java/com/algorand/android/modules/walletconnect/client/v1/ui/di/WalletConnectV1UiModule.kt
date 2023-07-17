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

package com.algorand.android.modules.walletconnect.client.v1.ui.di

import com.algorand.android.modules.walletconnect.client.v1.ui.launchback.WcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl
import com.algorand.android.modules.walletconnect.client.v1.ui.launchback.WcConnectionLaunchBackSessionInformationAnnotatedStringProviderV1Impl
import com.algorand.android.modules.walletconnect.client.v1.ui.launchback.WcConnectionLaunchBackTitleAnnotatedStringProviderV1Impl
import com.algorand.android.modules.walletconnect.client.v1.ui.launchback.WcTransactionLaunchBackDescriptionAnnotatedStringProviderV1Impl
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackDescriptionAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackSessionInformationAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WcConnectionLaunchBackTitleAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.launchback.transaction.ui.model.WcTransactionLaunchBackDescriptionAnnotatedStringProvider
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV1UiModule {

    @Provides
    @Named(WcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl.INJECTION_NAME)
    fun provideWcConnectionLaunchBackDescriptionAnnotatedStringProvider():
        WCConnectionLaunchBackDescriptionAnnotatedStringProvider {
        return WcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl()
    }

    @Provides
    @Named(WcConnectionLaunchBackSessionInformationAnnotatedStringProviderV1Impl.INJECTION_NAME)
    fun provideWcConnectionLaunchBackSessionInformationAnnotatedStringProvider():
        WCConnectionLaunchBackSessionInformationAnnotatedStringProvider {
        return WcConnectionLaunchBackSessionInformationAnnotatedStringProviderV1Impl()
    }

    @Provides
    @Named(WcConnectionLaunchBackTitleAnnotatedStringProviderV1Impl.INJECTION_NAME)
    fun provideWcConnectionLaunchBackTitleAnnotatedStringProvider():
        WcConnectionLaunchBackTitleAnnotatedStringProvider {
        return WcConnectionLaunchBackTitleAnnotatedStringProviderV1Impl()
    }

    @Provides
    @Named(WcTransactionLaunchBackDescriptionAnnotatedStringProviderV1Impl.INJECTION_NAME)
    fun provideWcTransactionLaunchBackDescriptionAnnotatedStringProvider():
        WcTransactionLaunchBackDescriptionAnnotatedStringProvider {
        return WcTransactionLaunchBackDescriptionAnnotatedStringProviderV1Impl()
    }
}
