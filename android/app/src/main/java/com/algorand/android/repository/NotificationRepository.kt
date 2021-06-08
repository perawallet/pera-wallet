/*
 * Copyright 2019 Algorand, Inc.
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

import android.content.SharedPreferences
import com.algorand.android.database.NotificationFilterDao
import com.algorand.android.models.DeviceRegistrationRequest
import com.algorand.android.models.DeviceUpdateRequest
import com.algorand.android.models.NotificationFilter
import com.algorand.android.models.NotificationFilterRequest
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.request
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.utils.Resource
import com.algorand.android.utils.preference.getNotificationUserId
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class NotificationRepository @Inject constructor(
    private val notificationFilterDao: NotificationFilterDao,
    private val sharedPref: SharedPreferences,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler
) {

    suspend fun postRequestRegisterDevice(deviceRegistrationRequest: DeviceRegistrationRequest) = request {
        mobileAlgorandApi.postRegisterDevice(deviceRegistrationRequest)
    }

    suspend fun putRequestUpdateDevice(deviceId: String, deviceUpdateRequest: DeviceUpdateRequest) =
        request { mobileAlgorandApi.putUpdateDevice(deviceId, deviceUpdateRequest) }

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
        val notificationUserId = sharedPref.getNotificationUserId()
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
                onFailed = { exception ->
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
}
