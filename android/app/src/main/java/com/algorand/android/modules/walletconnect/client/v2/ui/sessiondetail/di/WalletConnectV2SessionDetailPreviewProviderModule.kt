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

package com.algorand.android.modules.walletconnect.client.v2.ui.sessiondetail.di

import com.algorand.android.modules.walletconnect.client.v2.ui.sessiondetail.WalletConnectV2SessionDetailPreviewCheckSessionStatusProviderImpl
import com.algorand.android.modules.walletconnect.client.v2.ui.sessiondetail.WalletConnectV2SessionDetailPreviewVisibilityProviderImpl
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.sessiondetail.ui.mapper.WalletConnectSessionDetailPreviewCheckSessionStatusMapper
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewCheckSessionStatusProvider
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewVisibilityProvider
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV2SessionDetailPreviewProviderModule {

    @Provides
    @Named(WalletConnectV2SessionDetailPreviewCheckSessionStatusProviderImpl.INJECTION_NAME)
    fun provideWalletConnectSessionDetailPreviewCheckSessionStatusProvider(
        checkSessionStatusMapper: WalletConnectSessionDetailPreviewCheckSessionStatusMapper
    ): WalletConnectSessionDetailPreviewCheckSessionStatusProvider {
        return WalletConnectV2SessionDetailPreviewCheckSessionStatusProviderImpl(checkSessionStatusMapper)
    }

    @Provides
    @Named(WalletConnectV2SessionDetailPreviewVisibilityProviderImpl.INJECTION_NAME)
    fun provideWalletConnectSessionDetailPreviewVisibilityProvider(
        walletConnectManager: WalletConnectManager
    ): WalletConnectSessionDetailPreviewVisibilityProvider {
        return WalletConnectV2SessionDetailPreviewVisibilityProviderImpl(walletConnectManager)
    }
}
