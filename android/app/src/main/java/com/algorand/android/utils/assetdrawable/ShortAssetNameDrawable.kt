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
import com.algorand.android.utils.OvalTextDrawable
import com.algorand.android.utils.calculateTextSizeInBounds

class ShortAssetNameDrawable(val assetName: String) {

    @ColorRes
    private var textColor: Int = R.color.text_gray

    @ColorRes
    private var borderColor: Int = R.color.layer_gray_lighter

    @ColorRes
    private var backgroundColor: Int = R.color.background

    private val textPaint: Paint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
        textAlign = Paint.Align.CENTER
        textSize = calculateTextSizeInBounds(assetName, DEFAULT_SIZE - PADDING, DEFAULT_TEXT_SIZE, MIN_TEXT_SIZE_LIMIT)
    }

    private val borderPaint: Paint = Paint().apply {
        style = Paint.Style.STROKE
        strokeWidth = 1f
    }

    fun setTextColor(@ColorRes newTextColor: Int) {
        textColor = newTextColor
    }

    fun setBorderColor(@ColorRes newBorderColor: Int) {
        borderColor = newBorderColor
    }

    fun setBackgroundColor(@ColorRes newBackgroundColor: Int) {
        backgroundColor = newBackgroundColor
    }

    fun toDrawable(context: Context): Drawable {
        initTextColor(context)
        initBorderColor(context)
        return OvalTextDrawable(
            text = assetName,
            textPaint = textPaint,
            borderPaint = borderPaint,
            backgroundColor = ContextCompat.getColor(context, backgroundColor),
            height = DEFAULT_SIZE,
            width = DEFAULT_SIZE
        )
    }

    private fun initBorderColor(context: Context) {
        borderPaint.color = ContextCompat.getColor(context, borderColor)
    }

    private fun initTextColor(context: Context) {
        textPaint.color = ContextCompat.getColor(context, textColor)
    }

    companion object {
        private const val DEFAULT_SIZE = 24
        private const val DEFAULT_TEXT_SIZE = 20f
        private const val MIN_TEXT_SIZE_LIMIT = 8f
        private const val PADDING = 10
    }
}
