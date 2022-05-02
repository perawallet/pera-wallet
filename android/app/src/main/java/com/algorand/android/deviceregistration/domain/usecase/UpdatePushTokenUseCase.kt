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

import com.algorand.android.core.AccountManager
import com.algorand.android.deviceregistration.domain.mapper.DeviceUpdateDTOMapper
import com.algorand.android.deviceregistration.domain.model.DeviceUpdateDTO
import com.algorand.android.deviceregistration.domain.repository.UserDeviceIdRepository
import com.algorand.android.models.Result
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class UpdatePushTokenUseCase @Inject constructor(
    @Named(UserDeviceIdRepository.USER_DEVICE_ID_REPOSITORY_INJECTION_NAME)
    private val userDeviceIdRepository: UserDeviceIdRepository,
    private val deviceUpdateDTOMapper: DeviceUpdateDTOMapper,
    accountManager: AccountManager
) : BaseDeviceIdOperationUseCase(accountManager) {

    suspend fun updatePushToken(
        deviceId: String,
        token: String?,
        networkSlug: String?
    ): Flow<DataResource<String>> = flow {
        val deviceUpdateDTO = getDeviceUpdateDTO(deviceId, token, networkSlug)
        userDeviceIdRepository.updateDeviceId(deviceUpdateDTO).collect {
            when (it) {
                is Result.Success -> {
                    emit(DataResource.Success(it.data))
                }
                is Result.Error -> {
                    emit(DataResource.Error.Api<String>(it.exception, it.code))
                }
            }
        }
    }

    private fun getDeviceUpdateDTO(deviceId: String, token: String?, networkSlug: String?): DeviceUpdateDTO {
        return deviceUpdateDTOMapper.mapToDeviceUpdateDTO(
            deviceId,
            token,
            getAccountPublicKeys(),
            getApplicationName(),
            PLATFORM_NAME,
            getLocaleLanguageCode(),
            networkSlug
        )
    }
}
