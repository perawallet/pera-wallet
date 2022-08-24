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
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.drawable.Drawable
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.OvalShape
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.algorand.android.models.AccountIconResource

class AccountIconDrawable(
    private val backgroundColor: Int,
    private val iconTint: Int,
    private val iconDrawable: Drawable,
    private val size: Int
) : ShapeDrawable(OvalShape()) {

    private val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = backgroundColor
        style = Paint.Style.FILL
    }

    private var restoreCount: Int = 0

    private val backgroundRectF = RectF(0f, 0f, size.toFloat(), size.toFloat())

    private val iconPadding = size - (size * ICON_PADDING_RATIO_MULTIPLIER).toInt()

    init {
        intrinsicWidth = size
        intrinsicHeight = size
    }

    override fun draw(canvas: Canvas) {
        super.draw(canvas)
        restoreCount = canvas.save()
        drawBackground(canvas)
        drawAccountIcon(canvas)
        canvas.restoreToCount(restoreCount)
    }

    private fun drawBackground(canvas: Canvas) {
        canvas.drawOval(backgroundRectF, backgroundPaint)
    }

    private fun drawAccountIcon(canvas: Canvas) {
        iconDrawable.apply {
            setBounds(iconPadding, iconPadding, size - iconPadding, size - iconPadding)
            setTint(iconTint)
            draw(canvas)
        }
    }

    companion object {
        private const val ICON_PADDING_RATIO_MULTIPLIER = .8

        fun create(context: Context, accountIconResource: AccountIconResource, size: Int): AccountIconDrawable? {
            return AccountIconDrawable(
                backgroundColor = ContextCompat.getColor(context, accountIconResource.backgroundColorResId),
                iconTint = ContextCompat.getColor(context, accountIconResource.iconTintResId),
                iconDrawable = AppCompatResources.getDrawable(context, accountIconResource.iconResId) ?: return null,
                size = size
            )
        }
    }
}
