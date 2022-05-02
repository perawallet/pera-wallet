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

import com.algorand.android.cache.FirebasePushTokenSingleLocalCache
import com.algorand.android.deviceregistration.data.mapper.PushTokenDeleteRequestMapper
import com.algorand.android.deviceregistration.domain.model.DeleteDeviceDTO
import com.algorand.android.deviceregistration.domain.repository.FirebasePushTokenRepository
import com.algorand.android.models.Result
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.utils.CacheResult
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.flow

class FirebasePushTokenRepositoryImpl @Inject constructor(
    private val firebasePushTokenSingleLocalCache: FirebasePushTokenSingleLocalCache,
    private val pushTokenDeleteRequestMapper: PushTokenDeleteRequestMapper,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoErrorHandler: RetrofitErrorHandler
) : FirebasePushTokenRepository {

    override fun setPushToken(token: CacheResult<String>) {
        firebasePushTokenSingleLocalCache.put(token)
    }

    override fun getPushTokenOrNull(): CacheResult<String>? {
        return firebasePushTokenSingleLocalCache.getOrNull()
    }

    override fun clearPushToken(): CacheResult<String>? {
        return firebasePushTokenSingleLocalCache.remove()
    }

    override fun getPushTokenCacheFlow(): StateFlow<CacheResult<String>?> {
        return firebasePushTokenSingleLocalCache.cacheFlow
    }

    override suspend fun deleteDeviceFromApi(deleteDeviceDTO: DeleteDeviceDTO): Flow<Result<Any>> = flow {
        val pushTokenDeleteRequest = pushTokenDeleteRequestMapper.mapToPushTokenDeleteRequest(
            deleteDeviceDTO.pushToken,
            deleteDeviceDTO.platform
        )
        requestWithHipoErrorHandler(hipoErrorHandler) {
            mobileAlgorandApi.deletePushToken(deleteDeviceDTO.networkSlug, pushTokenDeleteRequest)
        }.use(
            onSuccess = { emit(Result.Success(it)) },
            onFailed = { exception, code -> emit(Result.Error(exception, code)) }
        )
    }
}
