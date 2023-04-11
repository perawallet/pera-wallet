package com.algorand.android.modules.notification.ui.mapper

import com.algorand.android.modules.notification.ui.model.NotificationCenterPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class NotificationCenterPreviewMapper @Inject constructor() {

    fun mapTo(onNotificationClickedEvent: Event<String>? = null): NotificationCenterPreview {
        return NotificationCenterPreview(onNotificationClickedEvent = onNotificationClickedEvent)
    }
}
