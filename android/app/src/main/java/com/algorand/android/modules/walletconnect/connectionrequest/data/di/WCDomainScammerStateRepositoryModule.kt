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

package com.algorand.android.modules.swap.assetswap.data.di

import com.algorand.android.modules.walletconnect.connectionrequest.data.repository.WCDomainDomainScammerStateRepositoryImpl
import com.algorand.android.modules.walletconnect.connectionrequest.domain.repository.WCDomainScammerStateRepository
import com.algorand.android.network.MobileAlgorandApi
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named

@Module
@InstallIn(SingletonComponent::class)
object WCDomainScammerStateRepositoryModule {

    @Named(WCDomainScammerStateRepository.INJECTION_NAME)
    @Provides
    fun provideWCDomainScammerStateRepository(
        mobileAlgorandApi: MobileAlgorandApi,
        hipoApiErrorHandler: RetrofitErrorHandler
    ): WCDomainScammerStateRepository {
        return WCDomainDomainScammerStateRepositoryImpl(
            mobileAlgorandApi,
            hipoApiErrorHandler
        )
    }
}
