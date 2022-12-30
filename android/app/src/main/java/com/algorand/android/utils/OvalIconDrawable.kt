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

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.drawable.Drawable
import android.graphics.drawable.shapes.OvalShape

class OvalIconDrawable(
    private val backgroundColor: Int,
    private val borderColor: Int,
    showBackground: Boolean,
    tintColor: Int,
    drawable: Drawable?,
    height: Int,
    width: Int
) : IconDrawable(drawable, tintColor, showBackground, height, width, OvalShape()) {

    private val backgroundPaint = Paint().apply {
        color = backgroundColor
    }

    private val borderPaint = Paint().apply {
        color = borderColor
        style = Paint.Style.STROKE
        strokeWidth = 1f
    }

    private val iconDrawableListener = object : Listener {
        override fun drawBorder(canvas: Canvas) {
            val rect = RectF(bounds)
            rect.inset(borderPaint.strokeWidth / 2, borderPaint.strokeWidth / 2)
            canvas.drawOval(rect, borderPaint)
        }

        override fun drawBackground(canvas: Canvas) {
            val backgroundRectF = RectF(bounds)
            canvas.drawOval(backgroundRectF, backgroundPaint)
        }
    }

    init {
        setListener(iconDrawableListener)
    }
}
