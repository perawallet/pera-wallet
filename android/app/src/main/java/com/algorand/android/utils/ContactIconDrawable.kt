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
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.algorand.android.R

class ContactIconDrawable(
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
        @DrawableRes
        private val DEFAULT_CONTACT_ICON_RES = R.drawable.ic_user

        @ColorRes
        private val DEFAULT_CONTACT_ICON_BG_COLOR = R.color.layer_gray_lighter

        @ColorRes
        private val DEFAULT_CONTACT_ICON_TINT_COLOR = R.color.text_gray

        private const val ICON_PADDING_RATIO_MULTIPLIER = .8

        fun create(context: Context, size: Int): ContactIconDrawable? {
            return ContactIconDrawable(
                backgroundColor = ContextCompat.getColor(context, DEFAULT_CONTACT_ICON_BG_COLOR),
                iconTint = ContextCompat.getColor(context, DEFAULT_CONTACT_ICON_TINT_COLOR),
                iconDrawable = AppCompatResources.getDrawable(context, DEFAULT_CONTACT_ICON_RES) ?: return null,
                size = size
            )
        }
    }
}
