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
import android.graphics.PixelFormat
import android.graphics.drawable.Drawable
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.Shape
import kotlin.math.roundToInt

abstract class IconDrawable(
    private val drawable: Drawable?,
    private val iconTint: Int,
    private val showBackground: Boolean,
    height: Int,
    width: Int,
    drawableShape: Shape
) : ShapeDrawable(drawableShape) {

    private var restoreCount: Int = 0

    private val safeWidth: Int = if (width < 0) bounds.width() else width
    private val safeHeight = if (height < 0) bounds.height() else height

    private val horizontalPadding = safeHeight.times(PADDING_RATIO).roundToInt()
    private val verticalPadding = safeWidth.times(PADDING_RATIO).roundToInt()

    private var listener: Listener? = null

    init {
        intrinsicWidth = width
        intrinsicHeight = height
    }

    protected fun setListener(listener: Listener) {
        this.listener = listener
    }

    override fun draw(canvas: Canvas) {
        super.draw(canvas)
        restoreCount = canvas.save()
        if (showBackground) listener?.drawBackground(canvas)
        listener?.drawBorder(canvas)
        drawIcon(canvas)
        listener?.drawColor(canvas)
        canvas.restoreToCount(restoreCount)
    }

    private fun drawIcon(canvas: Canvas) {
        drawable?.apply {
            setBounds(horizontalPadding, verticalPadding, safeWidth - horizontalPadding, safeHeight - verticalPadding)
            setTint(iconTint)
            draw(canvas)
        }
    }

    override fun getOpacity(): Int {
        return PixelFormat.TRANSLUCENT
    }

    interface Listener {
        fun drawBorder(canvas: Canvas) {}
        fun drawBackground(canvas: Canvas)
        fun drawColor(canvas: Canvas) {}
    }

    companion object {
        private const val PADDING_RATIO = .2f
    }
}
