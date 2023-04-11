package com.algorand.android.modules.notification.data.model

import com.google.gson.annotations.SerializedName

data class NotificationIconResponse(
    @SerializedName("logo")
    val prismUrl: String?,

    @SerializedName("shape")
    val shape: NotificationIconShapeResponse?
)
