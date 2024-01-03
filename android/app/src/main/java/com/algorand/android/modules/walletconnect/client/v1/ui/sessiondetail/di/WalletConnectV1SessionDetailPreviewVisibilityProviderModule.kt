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

package com.algorand.android.modules.walletconnect.client.v1.ui.sessiondetail.di

import com.algorand.android.modules.walletconnect.client.v1.ui.sessiondetail.WalletConnectV1SessionDetailPreviewInformationBadgeProviderImpl
import com.algorand.android.modules.walletconnect.client.v1.ui.sessiondetail.WalletConnectV1SessionDetailPreviewVisibilityProviderImpl
import com.algorand.android.modules.walletconnect.sessiondetail.ui.mapper.WalletConnectSessionDetailInformationBadgeMapper
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewInformationBadgeProvider
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewVisibilityProvider
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectV1SessionDetailPreviewVisibilityProviderModule {

    @Provides
    @Named(WalletConnectV1SessionDetailPreviewVisibilityProviderImpl.INJECTION_NAME)
    fun provideWalletConnectSessionDetailPreviewVisibilityProvider():
        WalletConnectSessionDetailPreviewVisibilityProvider {
        return WalletConnectV1SessionDetailPreviewVisibilityProviderImpl()
    }

    @Provides
    @Named(WalletConnectV1SessionDetailPreviewInformationBadgeProviderImpl.INJECTION_NAME)
    fun provideWalletConnectSessionDetailPreviewInformationBadgeProvider(
        informationBadgeMapper: WalletConnectSessionDetailInformationBadgeMapper
    ): WalletConnectSessionDetailPreviewInformationBadgeProvider {
        return WalletConnectV1SessionDetailPreviewInformationBadgeProviderImpl(informationBadgeMapper)
    }
}
