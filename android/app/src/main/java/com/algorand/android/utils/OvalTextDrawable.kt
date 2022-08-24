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
import android.graphics.drawable.shapes.OvalShape

class OvalTextDrawable(
    private val backgroundColor: Int,
    private val borderPaint: Paint? = null,
    text: String,
    textPaint: Paint,
    height: Int,
    width: Int
) : TextDrawable(text, textPaint, height, width, OvalShape()) {

    override fun drawBorder(canvas: Canvas) {
        borderPaint?.run {
            val rect = RectF(bounds)
            rect.inset(strokeWidth / 2, strokeWidth / 2)
            canvas.drawOval(rect, this)
        }
    }

    override fun drawBackground(canvas: Canvas) {
        val backgroundRectF = RectF(bounds)
        val backgroundPaint = Paint().apply {
            color = backgroundColor
        }
        canvas.drawOval(backgroundRectF, backgroundPaint)
    }
}
