package com.algorand.android.modules.notification.domain.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.notification.domain.model.LastSeenNotificationDTO
import com.algorand.android.modules.notification.domain.model.NotificationStatusDTO

interface NotificationStatusRepository {

    suspend fun getNotificationStatus(deviceId: String): Result<NotificationStatusDTO>

    suspend fun putLastSeenNotificationId(
        deviceId: String,
        lastSeenNotificationDTO: LastSeenNotificationDTO
    ): Result<LastSeenNotificationDTO>

    suspend fun cacheLastSeenNotificationId(notificationId: Long)

    suspend fun getCachedLastSeenNotificationId(): Long?

    companion object {
        const val REPOSITORY_INJECTION_NAME = "notificationStatusRepositoryInjection"
    }
}
