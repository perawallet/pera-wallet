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

package com.algorand.android.modules.notification.ui.utils

import android.content.Context
import android.graphics.drawable.Drawable
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.OvalIconDrawable

class FailedNotificationIconDrawable {

    fun toDrawable(context: Context): Drawable {
        return OvalIconDrawable(
            borderColor = ContextCompat.getColor(context, BORDER_COLOR),
            backgroundColor = ContextCompat.getColor(context, BACKGROUND_COLOR),
            tintColor = ContextCompat.getColor(context, TINT_COLOR),
            drawable = AppCompatResources.getDrawable(context, R.drawable.ic_close),
            height = DEFAULT_SIZE,
            width = DEFAULT_SIZE,
            showBackground = true
        )
    }

    companion object {
        private const val DEFAULT_SIZE = 40
        private const val BORDER_COLOR = R.color.error_tint_color
        private const val BACKGROUND_COLOR = R.color.error_tint_color
        private const val TINT_COLOR = R.color.background
    }
}
