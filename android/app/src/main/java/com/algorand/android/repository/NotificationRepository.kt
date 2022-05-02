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

package com.algorand.android.repository

import com.algorand.android.database.NotificationFilterDao
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.NotificationFilter
import com.algorand.android.models.NotificationFilterRequest
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.sharedpref.NotificationRefreshTimeLocalSource
import com.algorand.android.utils.Resource
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class NotificationRepository @Inject constructor(
    private val notificationFilterDao: NotificationFilterDao,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val notificationRefreshTimeLocalSource: NotificationRefreshTimeLocalSource
) {

    suspend fun getNotifications(notificationUserId: String) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getNotifications(notificationUserId)
    }

    suspend fun getNotificationsMore(nextUrl: String) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getNotificationsMore(nextUrl)
    }

    private suspend fun putNotificationFilter(
        deviceId: String,
        publicKey: String,
        notificationFilterRequest: NotificationFilterRequest
    ) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.putNotificationFilter(deviceId, publicKey, notificationFilterRequest)
    }

    suspend fun addNotificationFilter(publicKey: String, isFiltered: Boolean): Resource<Unit> {
        val notificationUserId = deviceIdUseCase.getSelectedNodeDeviceId()
        if (!notificationUserId.isNullOrBlank()) {
            addFilterToDatabase(publicKey, isFiltered)
            var result: Resource<Unit> = Resource.Error.Api(Exception())
            // TODO check if cancellation exception handling is needed here.
            putNotificationFilter(
                notificationUserId,
                publicKey,
                NotificationFilterRequest(isFiltered.not())
            ).use(
                onSuccess = {
                    result = Resource.Success(Unit)
                },
                onFailed = { exception, _ ->
                    // revert the operation
                    addFilterToDatabase(publicKey, isFiltered.not())
                    result = Resource.Error.Api(exception)
                }
            )
            return result
        } else {
            return Resource.Error.Api(Exception())
        }
    }

    private fun addFilterToDatabase(publicKey: String, isFiltered: Boolean) {
        if (isFiltered) {
            notificationFilterDao.insert(NotificationFilter(publicKey))
        } else {
            notificationFilterDao.delete(NotificationFilter(publicKey))
        }
    }

    fun saveLastRefreshedDateTime(lastRefreshedZonedDateTimeAsString: String) {
        notificationRefreshTimeLocalSource.saveData(lastRefreshedZonedDateTimeAsString)
    }

    fun getLastRefreshedDateTime(): String? {
        return notificationRefreshTimeLocalSource.getDataOrNull()
    }
}
