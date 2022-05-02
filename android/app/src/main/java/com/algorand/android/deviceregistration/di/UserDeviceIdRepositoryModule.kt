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

import com.algorand.android.deviceregistration.data.localsource.MainnetDeviceIdLocalSource
import com.algorand.android.deviceregistration.data.localsource.NotificationUserIdLocalSource
import com.algorand.android.deviceregistration.data.localsource.TestnetDeviceIdLocalSource
import com.algorand.android.deviceregistration.data.mapper.DeviceRegistrationRequestMapper
import com.algorand.android.deviceregistration.data.mapper.DeviceUpdateRequestMapper
import com.algorand.android.deviceregistration.data.repository.UserDeviceIdRepositoryImpl
import com.algorand.android.deviceregistration.domain.repository.UserDeviceIdRepository
import com.algorand.android.network.MobileAlgorandApi
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(ApplicationComponent::class)
object UserDeviceIdRepositoryModule {

    @Provides
    @Singleton
    @Named(UserDeviceIdRepository.USER_DEVICE_ID_REPOSITORY_INJECTION_NAME)
    internal fun provideUserDeviceIdRepository(
        mainnetDeviceIdLocalSource: MainnetDeviceIdLocalSource,
        testnetDeviceIdLocalSource: TestnetDeviceIdLocalSource,
        notificationUserIdLocalSource: NotificationUserIdLocalSource,
        mobileAlgorandApi: MobileAlgorandApi,
        deviceRegistrationRequestMapper: DeviceRegistrationRequestMapper,
        deviceUpdateRequestMapper: DeviceUpdateRequestMapper
    ): UserDeviceIdRepository {
        return UserDeviceIdRepositoryImpl(
            mainnetDeviceIdLocalSource,
            testnetDeviceIdLocalSource,
            notificationUserIdLocalSource,
            mobileAlgorandApi,
            deviceRegistrationRequestMapper,
            deviceUpdateRequestMapper
        )
    }
}
