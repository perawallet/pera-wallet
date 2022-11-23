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

package com.algorand.android.customviews.accountassetitem

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.appcompat.widget.AppCompatImageView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountAndAssetListBinding
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseAccountAndAssetItemView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    protected val binding = viewBinding(ItemAccountAndAssetListBinding::inflate)

    init {
        initRootView()
    }

    fun getStartIconImageView(): AppCompatImageView = binding.startIconImageView

    fun setStartIconDrawable(drawable: Drawable?, forceShow: Boolean = false) {
        binding.startIconImageView.apply {
            isVisible = drawable != null || forceShow
            setImageDrawable(drawable)
        }
    }

    fun setStartIconResource(@DrawableRes iconResId: Int?) {
        binding.startIconImageView.apply {
            isVisible = iconResId != null
            if (iconResId == null) return
            setImageResource(iconResId)
        }
    }

    fun setTitleText(title: String?) {
        binding.titleTextView.apply {
            isVisible = !title.isNullOrBlank()
            text = title
        }
    }

    fun setTitleTextColor(@ColorRes colorResId: Int) {
        val color = ContextCompat.getColor(context, colorResId)
        binding.titleTextView.setTextColor(color)
    }

    fun setDescriptionText(description: String?) {
        binding.descriptionTextView.apply {
            isVisible = !description.isNullOrBlank()
            text = description
        }
    }

    fun setDescriptionText(@StringRes textResId: Int) {
        binding.descriptionTextView.setText(textResId)
    }

    fun setEndIconDrawable(drawable: Drawable?) {
        binding.endIconImageView.apply {
            isVisible = drawable != null
            setImageDrawable(drawable)
        }
    }

    fun setEndIconResource(@DrawableRes endIconDrawableResId: Int) {
        binding.endIconImageView.setImageResource(endIconDrawableResId)
    }

    fun setStartSmallIconDrawable(drawable: Drawable?) {
        binding.startSmallIconImageView.apply {
            isVisible = drawable != null
            setImageDrawable(drawable)
        }
    }

    fun setStartSmallIconDrawableResource(@DrawableRes drawableResId: Int?) {
        binding.startSmallIconImageView.apply {
            if (drawableResId == null) {
                setImageDrawable(null)
            } else {
                setImageResource(drawableResId)
            }
        }
    }

    fun setPrimaryValueText(primaryValue: String?) {
        binding.primaryValueTextView.apply {
            isVisible = !primaryValue.isNullOrBlank()
            text = primaryValue
        }
    }

    fun setPrimaryValueText(primaryValue: String?, isPrimaryValueVisible: Boolean) {
        binding.primaryValueTextView.apply {
            isVisible = isPrimaryValueVisible
            text = primaryValue
        }
    }

    fun setSecondaryValueText(secondaryValue: String?) {
        binding.secondaryValueTextView.apply {
            isVisible = !secondaryValue.isNullOrBlank()
            text = secondaryValue
        }
    }

    fun setSecondaryValueText(secondaryValue: String?, isSecondaryValueVisible: Boolean) {
        binding.secondaryValueTextView.apply {
            isVisible = isSecondaryValueVisible
            text = secondaryValue
        }
    }

    fun setTrailingIconOfTitleText(@DrawableRes iconResId: Int?) {
        val endIconDrawable = if (iconResId != null) AppCompatResources.getDrawable(context, iconResId) else null
        binding.titleTextView.setDrawable(end = endIconDrawable)
    }

    fun setTrailingIconOfTitleText(iconDrawable: Drawable?) {
        binding.titleTextView.setDrawable(end = iconDrawable)
    }

    fun setStartIconProgressBarVisibility(isVisible: Boolean) {
        binding.startIconProgressBar.isVisible = isVisible
    }

    private fun initRootView() {
        val horizontalPadding = resources.getDimension(R.dimen.spacing_xlarge).toInt()
        updatePadding(left = horizontalPadding, right = horizontalPadding)
        minHeight = resources.getDimensionPixelSize(R.dimen.account_asset_item_view_min_height)
    }

    fun setPrimaryValueTextColor(@ColorRes colorResId: Int) {
        val color = ContextCompat.getColor(context, colorResId)
        binding.primaryValueTextView.setTextColor(color)
    }
}
