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

package com.algorand.android.utils

import android.content.Context
import android.graphics.Paint
import android.graphics.drawable.Drawable
import androidx.annotation.ColorRes
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import com.algorand.android.R
import com.algorand.android.utils.fonts.PeraFontResource

object BadgeDrawable {

    private const val DEFAULT_TEXT_SIZE = 24f
    private const val MIN_TEXT_SIZE_LIMIT = 8f

    fun toDrawable(
        context: Context,
        badgeText: String,
        @ColorRes textColor: Int,
        @ColorRes backgroundColor: Int
    ): Drawable {
        val badgeWidth = getBadgeWidth(context)
        val badgeHeight = getBadgeHeight(context)
        return RoundRectTextDrawable(
            backgroundColor = getBadgeBackgroundColor(context, backgroundColor),
            radiusAsPx = getBadgeCornerRadius(badgeHeight),
            text = badgeText,
            textPaint = getBadgeTextPaint(badgeWidth, badgeText, context, textColor),
            height = badgeHeight,
            width = badgeWidth,
            rectBackgroundColor = getBadgeRectBackgroundColor(context)
        )
    }

    private fun getBadgeTextPaint(width: Int, text: String, context: Context, textColor: Int): Paint {
        return Paint().apply {
            val badgeTextBadge = PeraFontResource.DmSans.Bold.getFont(context)
            typeface = ResourcesCompat.getFont(context, badgeTextBadge)
            isAntiAlias = true
            style = Paint.Style.FILL
            textAlign = Paint.Align.CENTER
            color = ContextCompat.getColor(context, textColor)
            textSize = calculateTextSizeInBounds(
                text = text,
                containerWidth = width,
                initialTextSize = DEFAULT_TEXT_SIZE,
                minTextSize = MIN_TEXT_SIZE_LIMIT
            )
            isFakeBoldText = true
        }
    }

    private fun getBadgeBackgroundColor(context: Context, backgroundColor: Int): Int {
        return ContextCompat.getColor(context, backgroundColor)
    }

    private fun getBadgeRectBackgroundColor(context: Context): Int {
        return ContextCompat.getColor(context, R.color.primary_background)
    }

    private fun getBadgeCornerRadius(height: Int): Float {
        return height / 2f
    }

    private fun getBadgeWidth(context: Context): Int {
        return context.resources.getDimensionPixelSize(R.dimen.new_badge_width)
    }

    private fun getBadgeHeight(context: Context): Int {
        return context.resources.getDimensionPixelSize(R.dimen.new_badge_height)
    }
}
