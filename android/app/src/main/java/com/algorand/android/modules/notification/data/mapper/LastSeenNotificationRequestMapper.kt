package com.algorand.android.modules.notification.data.mapper

import com.algorand.android.modules.notification.data.model.LastSeenNotificationRequest
import javax.inject.Inject

class LastSeenNotificationRequestMapper @Inject constructor() {

    fun mapToLastSeenNotificationRequest(notificationId: Long?): LastSeenNotificationRequest {
        return LastSeenNotificationRequest(lastSeenNotificationId = notificationId)
    }
}
