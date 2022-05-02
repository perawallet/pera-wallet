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

package com.algorand.android.deviceregistration.domain.usecase

import com.algorand.android.utils.DataResource
import java.net.HttpURLConnection
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class DeviceRegistrationUseCase @Inject constructor(
    private val deviceIdUseCase: DeviceIdUseCase,
    private val registerDeviceIdUseCase: RegisterDeviceIdUseCase,
    private val updatePushTokenUseCase: UpdatePushTokenUseCase
) {

    fun registerDevice(token: String): Flow<DataResource<String>> = flow {
        when (val deviceId = deviceIdUseCase.getSelectedNodeDeviceId()) {
            null -> registerDeviceIdUseCase.registerDevice(token).collect { emit(it) }
            else -> updatePushTokenUseCase.updatePushToken(deviceId, token, null).collect {
                if (it is DataResource.Error.Api && it.code == HttpURLConnection.HTTP_NOT_FOUND) {
                    registerDeviceIdUseCase.registerDevice(token).collect { emit(it) }
                }
            }
        }
    }
}
