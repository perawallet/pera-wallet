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
import androidx.core.content.ContextCompat
import com.algorand.android.R

object TestnetBadgeDrawable {

    private const val DEFAULT_TEXT_SIZE = 24f
    private const val MIN_TEXT_SIZE_LIMIT = 8f

    fun toDrawable(context: Context): Drawable {
        val badgeWidth = getTestnetBadgeWidth(context)
        val badgeHeight = getTestnetBadgeHeight(context)
        val badgeText = getTestnetBadgeText(context)
        return RoundRectTextDrawable(
            backgroundColor = getTestnetBadgeBackgroundColor(context),
            radiusAsPx = getTestnetBadgeCornerRadius(badgeHeight),
            text = badgeText,
            textPaint = getTestnetBadgeTextPaint(badgeWidth, badgeText, context),
            height = badgeHeight,
            width = badgeWidth,
            rectBackgroundColor = getTestnetBadgeRectBackgroundColor(context)
        )
    }

    private fun getTestnetBadgeText(context: Context): String {
        return context.getString(R.string.testnet)
    }

    private fun getTestnetBadgeTextPaint(width: Int, text: String, context: Context): Paint {
        return Paint().apply {
            isAntiAlias = true
            style = Paint.Style.FILL
            textAlign = Paint.Align.CENTER
            color = ContextCompat.getColor(context, R.color.testnet_text)
            textSize = calculateTextSizeInBounds(
                text = text,
                containerWidth = width,
                initialTextSize = DEFAULT_TEXT_SIZE,
                minTextSize = MIN_TEXT_SIZE_LIMIT
            )
        }
    }

    private fun getTestnetBadgeBackgroundColor(context: Context): Int {
        return ContextCompat.getColor(context, R.color.testnet_bg)
    }

    private fun getTestnetBadgeRectBackgroundColor(context: Context): Int {
        return ContextCompat.getColor(context, R.color.primary_background)
    }

    private fun getTestnetBadgeCornerRadius(height: Int): Float {
        return height / 2f
    }

    private fun getTestnetBadgeWidth(context: Context): Int {
        return context.resources.getDimensionPixelSize(R.dimen.testnet_badge_width)
    }

    private fun getTestnetBadgeHeight(context: Context): Int {
        return context.resources.getDimensionPixelSize(R.dimen.testnet_badge_height)
    }
}
