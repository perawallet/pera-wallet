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
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.Shape

abstract class TextDrawable(
    private val text: String,
    private val textPaint: Paint,
    private val height: Int,
    private val width: Int,
    drawableShape: Shape
) : ShapeDrawable(drawableShape) {

    init {
        intrinsicWidth = width
        intrinsicHeight = height
    }

    abstract fun drawBorder(canvas: Canvas)
    abstract fun drawBackground(canvas: Canvas)

    override fun draw(canvas: Canvas) {
        super.draw(canvas)
        val count: Int = canvas.save()
        drawBackground(canvas)
        drawBorder(canvas)
        drawText(canvas)
        canvas.restoreToCount(count)
    }

    private fun drawText(canvas: Canvas) {
        val width = if (width < 0) bounds.width() else width
        val height = if (height < 0) bounds.height() else height
        canvas.drawText(text, width / 2f, height / 2 - (textPaint.descent() + textPaint.ascent()) / 2, textPaint)
    }

    override fun setAlpha(alpha: Int) {
        textPaint.alpha = alpha
    }

    override fun setColorFilter(cf: ColorFilter?) {
        textPaint.colorFilter = cf
    }

    override fun getOpacity(): Int {
        return PixelFormat.TRANSLUCENT
    }
}
