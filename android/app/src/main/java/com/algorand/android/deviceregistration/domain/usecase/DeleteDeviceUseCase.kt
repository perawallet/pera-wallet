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

import com.algorand.android.deviceregistration.domain.mapper.DeleteDeviceDTOMapper
import com.algorand.android.deviceregistration.domain.repository.FirebasePushTokenRepository
import com.algorand.android.deviceregistration.domain.usecase.BaseDeviceIdOperationUseCase.Companion.PLATFORM_NAME
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class DeleteDeviceUseCase @Inject constructor(
    @Named(FirebasePushTokenRepository.FIREBASE_PUSH_TOKEN_REPOSITORY_INJECTION_NAME)
    private val firebasePushTokenRepository: FirebasePushTokenRepository,
    private val deleteDeviceDTOMapper: DeleteDeviceDTOMapper
) {

    suspend fun deleteDevice(networkSlug: String): Flow<DataResource<Unit>> = flow {
        val pushToken = firebasePushTokenRepository.getPushTokenOrNull()?.data ?: return@flow
        emit(DataResource.Loading())
        val deletePushTokenDTO = deleteDeviceDTOMapper.mapToDeleteDeviceDTO(networkSlug, pushToken, PLATFORM_NAME)
        firebasePushTokenRepository.deleteDeviceFromApi(deletePushTokenDTO).collect {
            it.use(
                onSuccess = { emit(DataResource.Success(Unit)) },
                onFailed = { exception, code -> emit(DataResource.Error.Api<Unit>(exception, code)) }
            )
        }
    }
}
