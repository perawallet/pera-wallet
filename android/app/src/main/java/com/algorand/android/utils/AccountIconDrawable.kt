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
import android.graphics.drawable.Drawable
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.OvalShape
import androidx.annotation.DimenRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview

class AccountIconDrawable(
    private val backgroundColor: Int,
    private val iconTint: Int,
    private val iconDrawable: Drawable?,
    private val size: Int
) : ShapeDrawable(OvalShape()) {

    private var restoreCount: Int = 0

    private val iconPadding = size - (size * ICON_PADDING_RATIO_MULTIPLIER).toInt()

    init {
        intrinsicWidth = size
        intrinsicHeight = size
        setTint(backgroundColor)
    }

    override fun draw(canvas: Canvas) {
        super.draw(canvas)
        restoreCount = canvas.save()
        drawAccountIcon(canvas)
        canvas.restoreToCount(restoreCount)
    }

    private fun drawAccountIcon(canvas: Canvas) {
        iconDrawable?.apply {
            setBounds(iconPadding, iconPadding, size - iconPadding, size - iconPadding)
            setTint(iconTint)
            draw(canvas)
        }
    }

    companion object {
        private const val ICON_PADDING_RATIO_MULTIPLIER = .8

        fun create(
            context: Context,
            @DimenRes sizeResId: Int,
            accountIconDrawablePreview: AccountIconDrawablePreview
        ): AccountIconDrawable {
            val backgroundColor = ContextCompat.getColor(context, accountIconDrawablePreview.backgroundColorResId)
            val iconTint = ContextCompat.getColor(context, accountIconDrawablePreview.iconTintResId)
            val iconDrawable = AppCompatResources.getDrawable(context, accountIconDrawablePreview.iconResId)?.mutate()
            val size = context.resources.getDimensionPixelSize(sizeResId)
            return AccountIconDrawable(
                backgroundColor = backgroundColor,
                iconTint = iconTint,
                iconDrawable = iconDrawable,
                size = size
            )
        }

        fun create(context: Context, accountIconResource: AccountIconResource, size: Int): AccountIconDrawable? {
            return AccountIconDrawable(
                backgroundColor = ContextCompat.getColor(context, accountIconResource.backgroundColorResId),
                iconTint = ContextCompat.getColor(context, accountIconResource.iconTintResId),
                iconDrawable = AppCompatResources.getDrawable(context, accountIconResource.iconResId)?.mutate()
                    ?: return null,
                size = size
            )
        }
    }
}
