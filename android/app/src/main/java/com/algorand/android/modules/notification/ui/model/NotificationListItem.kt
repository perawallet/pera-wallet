package com.algorand.android.modules.notification.ui.model

import com.algorand.android.modules.notification.ui.utils.NotificationIconDrawableProvider
import java.time.ZonedDateTime

data class NotificationListItem(
    val id: Long,
    val uri: String?,
    val isFailed: Boolean,
    val timeDifference: Long,
    val creationDateTime: ZonedDateTime,
    val message: String,
    val notificationIconDrawableProvider: NotificationIconDrawableProvider
)
