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

package com.algorand.android.deviceregistration.domain.repository

import com.algorand.android.deviceregistration.domain.model.DeleteDeviceDTO
import com.algorand.android.models.Result
import com.algorand.android.utils.CacheResult
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow

interface FirebasePushTokenRepository {

    fun setPushToken(token: CacheResult<String>)

    fun getPushTokenOrNull(): CacheResult<String>?

    fun clearPushToken(): CacheResult<String>?

    fun getPushTokenCacheFlow(): StateFlow<CacheResult<String>?>

    suspend fun deleteDeviceFromApi(deleteDeviceDTO: DeleteDeviceDTO): Flow<Result<Any>>

    companion object {
        const val FIREBASE_PUSH_TOKEN_REPOSITORY_INJECTION_NAME = "firebasePushTokenInjection"
    }
}
