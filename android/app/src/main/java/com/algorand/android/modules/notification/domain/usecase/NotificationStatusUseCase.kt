package com.algorand.android.modules.notification.domain.usecase

import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.Result
import com.algorand.android.modules.notification.data.mapper.LastSeenNotificationDTOMapper
import com.algorand.android.modules.notification.domain.repository.NotificationStatusRepository
import com.algorand.android.modules.notification.ui.model.NotificationListItem
import javax.inject.Inject
import javax.inject.Named

class NotificationStatusUseCase @Inject constructor(
    @Named(NotificationStatusRepository.REPOSITORY_INJECTION_NAME)
    private val notificationStatusRepository: NotificationStatusRepository,
    private val deviceIdUseCase: DeviceIdUseCase,
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
                notificationId = notificationListItem.id
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
