package com.algorand.android.modules.notification.ui.utils

import android.content.Context
import android.graphics.drawable.Drawable
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.OvalIconDrawable

class NotificationPlaceholderDrawable {

    fun toDrawable(context: Context): Drawable {
        return OvalIconDrawable(
            borderColor = ContextCompat.getColor(context, BORDER_COLOR),
            backgroundColor = ContextCompat.getColor(context, BACKGROUND_COLOR),
            tintColor = ContextCompat.getColor(context, TINT_COLOR),
            drawable = AppCompatResources.getDrawable(context, R.drawable.ic_bell),
            height = DEFAULT_SIZE,
            width = DEFAULT_SIZE,
            showBackground = true
        )
    }

    companion object {
        private const val DEFAULT_SIZE = 40
        private const val BORDER_COLOR = R.color.notification_icon_placeholder_border_color
        private const val BACKGROUND_COLOR = R.color.primary_background
        private const val TINT_COLOR = R.color.notification_icon_placeholder_tint_color
    }
}
