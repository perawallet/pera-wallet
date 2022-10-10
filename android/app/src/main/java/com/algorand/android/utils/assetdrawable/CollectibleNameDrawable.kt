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

package com.algorand.android.utils.assetdrawable

import android.content.Context
import android.graphics.Paint
import android.graphics.drawable.Drawable
import androidx.annotation.ColorRes
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.RoundRectTextDrawable
import com.algorand.android.utils.calculateTextSizeInBounds

class CollectibleNameDrawable(val collectibleName: String, val width: Int) {

    @ColorRes
    private var textColor: Int = R.color.secondary_text_color

    @ColorRes
    private var backgroundColor: Int = R.color.layer_gray_lighter

    private val textPaint: Paint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
        textAlign = Paint.Align.CENTER
        textSize = calculateTextSizeInBounds(
            text = collectibleName,
            containerWidth = width - PADDING,
            initialTextSize = DEFAULT_TEXT_SIZE,
            minTextSize = MIN_TEXT_SIZE_LIMIT
        )
    }

    fun setTextColor(@ColorRes newTextColor: Int) {
        textColor = newTextColor
    }

    fun setBackgroundColor(@ColorRes newBackgroundColor: Int) {
        backgroundColor = newBackgroundColor
    }

    fun toDrawable(context: Context): Drawable {
        initTextColor(context)
        val backgroundColor = ContextCompat.getColor(context, backgroundColor)
        val rectBackgroundColor = ContextCompat.getColor(context, R.color.primary_background)
        val cornerRadius = context.resources.getDimension(R.dimen.collectible_image_view_radius)
        return RoundRectTextDrawable(
            backgroundColor = backgroundColor,
            radiusAsPx = cornerRadius,
            text = collectibleName,
            textPaint = textPaint,
            height = width,
            width = width,
            rectBackgroundColor = rectBackgroundColor
        )
    }

    private fun initTextColor(context: Context) {
        textPaint.color = ContextCompat.getColor(context, textColor)
    }

    companion object {
        private const val DEFAULT_TEXT_SIZE = 28f
        private const val MIN_TEXT_SIZE_LIMIT = 8f
        private const val PADDING = 10
    }
}
