package com.algorand.android.modules.notification.ui.model

import com.algorand.android.utils.Event

data class NotificationCenterPreview(
    val onNotificationClickedEvent: Event<String>?
)
