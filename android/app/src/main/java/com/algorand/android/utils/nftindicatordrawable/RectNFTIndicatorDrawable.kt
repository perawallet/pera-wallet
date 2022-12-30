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

package com.algorand.android.utils.nftindicatordrawable

import android.content.Context
import android.graphics.drawable.Drawable
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.RectIconDrawable

class RectNFTIndicatorDrawable private constructor(
    @DrawableRes private val drawableResId: Int,
    @ColorRes private val tintColor: Int,
    @ColorRes private val backgroundColor: Int
) : BaseNFTIndicatorDrawable() {

    override fun toDrawable(
        context: Context,
        showBackground: Boolean
    ): Drawable {
        return RectIconDrawable(
            backgroundColor = ContextCompat.getColor(context, backgroundColor),
            tintColor = ContextCompat.getColor(context, tintColor),
            drawable = ContextCompat.getDrawable(context, drawableResId)?.mutate(),
            height = DEFAULT_SIZE,
            width = DEFAULT_SIZE,
            showBackground = showBackground,
            radius = DEFAULT_RADIUS
        )
    }

    override fun equals(other: Any?): Boolean {
        if (other !is RectNFTIndicatorDrawable) return false
        if (drawableResId != other.drawableResId) return false
        if (tintColor != other.tintColor) return false
        if (backgroundColor != other.backgroundColor) return false
        return true
    }

    @Suppress("MagicNumber")
    override fun hashCode(): Int {
        var result = drawableResId.hashCode()
        result = 31 * result + tintColor.hashCode()
        result = 31 * result + backgroundColor.hashCode()
        return result
    }

    companion object {

        private const val DEFAULT_SIZE = 28
        private const val DEFAULT_RADIUS = 4f

        fun create(
            @DrawableRes drawableResId: Int,
            @ColorRes tintColor: Int,
            @ColorRes backgroundColor: Int = R.color.gray_900_alpha_60
        ): RectNFTIndicatorDrawable {
            return RectNFTIndicatorDrawable(
                drawableResId = drawableResId,
                tintColor = tintColor,
                backgroundColor = backgroundColor
            )
        }
    }
}
