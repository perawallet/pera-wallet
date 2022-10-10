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

package com.algorand.android.modules.accounts.domain.usecase

import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.Result
import com.algorand.android.modules.accounts.data.mapper.LastSeenNotificationDTOMapper
import com.algorand.android.modules.accounts.domain.repository.NotificationStatusRepository
import com.algorand.android.modules.accounts.domain.repository.NotificationStatusRepository.Companion.REPOSITORY_INJECTION_NAME
import com.algorand.android.usecase.GetActiveNodeUseCase
import javax.inject.Inject
import javax.inject.Named

class NotificationStatusUseCase @Inject constructor(
    @Named(REPOSITORY_INJECTION_NAME) private val notificationStatusRepository: NotificationStatusRepository,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val getActiveNodeUseCase: GetActiveNodeUseCase,
    private val lastSeenNotificationDTOMapper: LastSeenNotificationDTOMapper
) {

    suspend fun hasNewNotification(): Boolean {
        return deviceIdUseCase.getSelectedNodeDeviceId()?.let { deviceId ->
            when (val response = notificationStatusRepository.getNotificationStatus(deviceId = deviceId)) {
                is Result.Success -> response.data.hasNewNotification
                is Result.Error -> false
            }
        } ?: false
    }

    suspend fun updateLastSeenNotificationId(notificationListItem: NotificationListItem) {
        if (isNotificationIdAlreadyExist(notificationId = notificationListItem.id)) return
        val deviceId = deviceIdUseCase.getSelectedNodeDeviceId() ?: return
        notificationStatusRepository.putLastSeenNotificationId(
            deviceId = deviceId,
            lastSeenNotificationDTO = lastSeenNotificationDTOMapper.mapToLastSeenNotificationDTO(
                notificationId = notificationListItem.id,
                networkSlug = getActiveNodeUseCase.getActiveNode()?.networkSlug
            )
        ).use(
            onSuccess = { lastSeenNotificationDTO ->
                lastSeenNotificationDTO.notificationId?.let { id ->
                    notificationStatusRepository.cacheLastSeenNotificationId(notificationId = id)
                }
            }
        )
    }

    private suspend fun isNotificationIdAlreadyExist(notificationId: Long?): Boolean {
        val cachedNotificationId = notificationStatusRepository.getCachedLastSeenNotificationId()
        return cachedNotificationId?.let { it == notificationId } ?: false
    }
}
