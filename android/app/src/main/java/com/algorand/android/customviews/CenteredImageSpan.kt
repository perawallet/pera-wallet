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

package com.algorand.android.customviews

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Paint.FontMetricsInt
import android.graphics.drawable.Drawable
import android.text.style.ImageSpan
import androidx.annotation.DrawableRes
import java.lang.ref.WeakReference

class CenteredImageSpan(context: Context, @DrawableRes drawableRes: Int) : ImageSpan(context, drawableRes) {

    private var drawableWeekReference: WeakReference<Drawable>? = null

    // Redefined locally because it is a private member from DynamicDrawableSpan
    private val cachedDrawable: Drawable
        get() {
            return drawableWeekReference?.get() ?: run {
                drawableWeekReference = WeakReference(drawable)
                return@run drawable
            }
        }

    override fun getSize(
        paint: Paint,
        text: CharSequence,
        start: Int,
        end: Int,
        fm: FontMetricsInt?
    ): Int {
        val rect = cachedDrawable.bounds
        if (fm != null) {
            val pfm = paint.fontMetricsInt
            // keep it the same as paint's fm
            fm.ascent = pfm.ascent
            fm.descent = pfm.descent
            fm.top = pfm.top
            fm.bottom = pfm.bottom
        }
        return rect.right
    }

    override fun draw(
        canvas: Canvas,
        text: CharSequence,
        start: Int,
        end: Int,
        x: Float,
        top: Int,
        y: Int,
        bottom: Int,
        paint: Paint
    ) {
        canvas.save()
        val drawableHeight = cachedDrawable.intrinsicHeight
        val fontAscent = paint.fontMetricsInt.ascent
        val fontDescent = paint.fontMetricsInt.descent
        val transY = bottom - cachedDrawable.bounds.bottom + ((drawableHeight - fontDescent + fontAscent) / 2)
        canvas.translate(x, transY.toFloat())
        cachedDrawable.draw(canvas)
        canvas.restore()
    }
}
