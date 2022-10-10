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

package com.algorand.android.modules.accounts.data.repository

import com.algorand.android.modules.accounts.data.cache.LastSeenNotificationIdLocalSource
import com.algorand.android.modules.accounts.data.mapper.LastSeenNotificationDTOMapper
import com.algorand.android.modules.accounts.data.mapper.LastSeenNotificationRequestMapper
import com.algorand.android.modules.accounts.data.mapper.NotificationStatusDTOMapper
import com.algorand.android.modules.accounts.domain.model.LastSeenNotificationDTO
import com.algorand.android.modules.accounts.domain.repository.NotificationStatusRepository
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class NotificationStatusRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val lastSeenNotificationRequestMapper: LastSeenNotificationRequestMapper,
    private val notificationStatusDTOMapper: NotificationStatusDTOMapper,
    private val lastSeenNotificationDTOMapper: LastSeenNotificationDTOMapper,
    private val lastSeenNotificationIdLocalSource: LastSeenNotificationIdLocalSource,
) : NotificationStatusRepository {

    override suspend fun getNotificationStatus(deviceId: String) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getNotificationStatus(deviceId = deviceId)
    }.map { notificationStatusResponse ->
        notificationStatusDTOMapper.mapToNotificationStatusDTO(
            hasNewNotification = notificationStatusResponse.hasNewNotification
        )
    }

    override suspend fun putLastSeenNotificationId(
        deviceId: String,
        lastSeenNotificationDTO: LastSeenNotificationDTO
    ) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        val lastSeenNotificationRequest = lastSeenNotificationRequestMapper.mapToLastSeenNotificationRequest(
            notificationId = lastSeenNotificationDTO.notificationId
        )
        mobileAlgorandApi.putLastSeenNotification(
            deviceId = deviceId,
            lastSeenRequest = lastSeenNotificationRequest,
            networkSlug = lastSeenNotificationDTO.networkSlug
        )
    }.map { lastSeenNotificationResponse ->
        lastSeenNotificationDTOMapper.mapToLastSeenNotificationDTO(
            notificationId = lastSeenNotificationResponse.lastSeenNotificationId,
            networkSlug = lastSeenNotificationDTO.networkSlug
        )
    }

    override suspend fun cacheLastSeenNotificationId(notificationId: Long) {
        lastSeenNotificationIdLocalSource.saveData(data = notificationId)
    }

    override suspend fun getCachedLastSeenNotificationId(): Long? {
        return lastSeenNotificationIdLocalSource.getDataOrNull()
    }
}
