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

package com.algorand.android.deviceregistration.di

import com.algorand.android.cache.FirebasePushTokenSingleLocalCache
import com.algorand.android.deviceregistration.data.mapper.PushTokenDeleteRequestMapper
import com.algorand.android.deviceregistration.data.repository.FirebasePushTokenRepositoryImpl
import com.algorand.android.deviceregistration.domain.repository.FirebasePushTokenRepository
import com.algorand.android.network.MobileAlgorandApi
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(ApplicationComponent::class)
object FirebasePushTokenRepositoryModule {

    @Provides
    @Singleton
    @Named(FirebasePushTokenRepository.FIREBASE_PUSH_TOKEN_REPOSITORY_INJECTION_NAME)
    internal fun provideFirebasePushTokenRepository(
        firebasePushTokenSingleLocalCache: FirebasePushTokenSingleLocalCache,
        pushTokenDeleteRequestMapper: PushTokenDeleteRequestMapper,
        mobileAlgorandApi: MobileAlgorandApi,
        hipoErrorHandler: RetrofitErrorHandler
    ): FirebasePushTokenRepository {
        return FirebasePushTokenRepositoryImpl(
            firebasePushTokenSingleLocalCache,
            pushTokenDeleteRequestMapper,
            mobileAlgorandApi,
            hipoErrorHandler
        )
    }
}
