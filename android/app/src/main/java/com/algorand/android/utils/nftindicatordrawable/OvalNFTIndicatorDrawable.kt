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
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.OvalIconDrawable

class OvalNFTIndicatorDrawable private constructor(
    @DrawableRes private val drawableResId: Int,
    @ColorRes private val tintColor: Int,
    @ColorRes private val borderColor: Int,
    @ColorRes private val backgroundColor: Int
) : BaseNFTIndicatorDrawable() {

    override fun toDrawable(
        context: Context,
        showBackground: Boolean,
    ): Drawable {
        return OvalIconDrawable(
            borderColor = ContextCompat.getColor(context, borderColor),
            backgroundColor = ContextCompat.getColor(context, backgroundColor),
            tintColor = ContextCompat.getColor(context, tintColor),
            drawable = AppCompatResources.getDrawable(context, drawableResId)?.mutate(),
            height = DEFAULT_SIZE,
            width = DEFAULT_SIZE,
            showBackground = showBackground
        )
    }

    override fun equals(other: Any?): Boolean {
        if (other !is OvalNFTIndicatorDrawable) return false
        if (drawableResId != other.drawableResId) return false
        if (tintColor != other.tintColor) return false
        if (borderColor != other.borderColor) return false
        if (backgroundColor != other.backgroundColor) return false
        return true
    }

    @Suppress("MagicNumber")
    override fun hashCode(): Int {
        var result = drawableResId.hashCode()
        result = 31 * result + tintColor.hashCode()
        result = 31 * result + borderColor.hashCode()
        result = 31 * result + backgroundColor.hashCode()
        return result
    }

    companion object {

        private const val DEFAULT_SIZE = 24

        fun create(
            @DrawableRes drawableResId: Int,
            @ColorRes tintColor: Int,
            @ColorRes borderColor: Int = R.color.layer_gray_lighter,
            @ColorRes backgroundColor: Int = R.color.background
        ): OvalNFTIndicatorDrawable {
            return OvalNFTIndicatorDrawable(
                drawableResId = drawableResId,
                tintColor = tintColor,
                borderColor = borderColor,
                backgroundColor = backgroundColor
            )
        }
    }
}
