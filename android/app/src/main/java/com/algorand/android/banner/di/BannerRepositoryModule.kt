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

package com.algorand.android.banner.di

import com.algorand.android.banner.data.cache.BannerIdsLocalSource
import com.algorand.android.banner.data.cache.BannerLocalCache
import com.algorand.android.banner.data.mapper.BannerDetailDTOMapper
import com.algorand.android.banner.data.repository.BannerRepositoryImpl
import com.algorand.android.banner.domain.repository.BannerRepository
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
object BannerRepositoryModule {

    @Provides
    @Singleton
    @Named(BannerRepository.BANNER_REPOSITORY_INJECTION_NAME)
    internal fun provideBannerRepository(
        mobileAlgorandApi: MobileAlgorandApi,
        hipoErrorHandler: RetrofitErrorHandler,
        bannerDetailDTOMapper: BannerDetailDTOMapper,
        bannerLocalCache: BannerLocalCache,
        bannerIdsLocalSource: BannerIdsLocalSource
    ): BannerRepository {
        return BannerRepositoryImpl(
            mobileAlgorandApi,
            hipoErrorHandler,
            bannerDetailDTOMapper,
            bannerLocalCache,
            bannerIdsLocalSource
        )
    }
}
