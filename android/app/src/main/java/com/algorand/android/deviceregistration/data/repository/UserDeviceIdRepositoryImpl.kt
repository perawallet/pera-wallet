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

package com.algorand.android.deviceregistration.data.repository

import com.algorand.android.deviceregistration.data.localsource.MainnetDeviceIdLocalSource
import com.algorand.android.deviceregistration.data.localsource.NotificationUserIdLocalSource
import com.algorand.android.deviceregistration.data.localsource.TestnetDeviceIdLocalSource
import com.algorand.android.deviceregistration.data.mapper.DeviceRegistrationRequestMapper
import com.algorand.android.deviceregistration.data.mapper.DeviceUpdateRequestMapper
import com.algorand.android.deviceregistration.domain.model.DeviceRegistrationDTO
import com.algorand.android.deviceregistration.domain.model.DeviceUpdateDTO
import com.algorand.android.deviceregistration.domain.repository.UserDeviceIdRepository
import com.algorand.android.models.Result
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.request
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class UserDeviceIdRepositoryImpl @Inject constructor(
    private val mainnetDeviceIdLocalSource: MainnetDeviceIdLocalSource,
    private val testnetDeviceIdLocalSource: TestnetDeviceIdLocalSource,
    private val notificationUserIdLocalSource: NotificationUserIdLocalSource,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val deviceRegistrationRequestMapper: DeviceRegistrationRequestMapper,
    private val deviceUpdateRequestMapper: DeviceUpdateRequestMapper
) : UserDeviceIdRepository {

    override fun setMainnetDeviceId(deviceId: String?) {
        mainnetDeviceIdLocalSource.saveData(deviceId)
    }

    override fun getMainnetDeviceId(): String? {
        return mainnetDeviceIdLocalSource.getDataOrNull()
    }

    override fun setTestnetDeviceId(deviceId: String?) {
        testnetDeviceIdLocalSource.saveData(deviceId)
    }

    override fun getTestnetDevideId(): String? {
        return testnetDeviceIdLocalSource.getDataOrNull()
    }

    override fun setNotificationUserId(deviceId: String?) {
        notificationUserIdLocalSource.saveData(deviceId)
    }

    override fun getNotificationUserId(): String? {
        return notificationUserIdLocalSource.getDataOrNull()
    }

    override suspend fun registerDeviceId(deviceRegistrationDTO: DeviceRegistrationDTO): Flow<Result<String>> = flow {
        val deviceRegistrationRequest = deviceRegistrationRequestMapper
            .mapToDeviceRegistrationRequest(deviceRegistrationDTO)
        val result = request { mobileAlgorandApi.postRegisterDevice(deviceRegistrationRequest) }.map {
            it.userId.orEmpty()
        }
        emit(result)
    }

    override suspend fun updateDeviceId(deviceUpdateDTO: DeviceUpdateDTO): Flow<Result<String>> = flow {
        val deviceUpdateRequest = deviceUpdateRequestMapper.mapToDeviceUpdateRequest(deviceUpdateDTO)
        val result = request {
            with(deviceUpdateDTO) { mobileAlgorandApi.putUpdateDevice(deviceId, deviceUpdateRequest, networkSlug) }
        }.map {
            it.userId.orEmpty()
        }
        emit(result)
    }
}
