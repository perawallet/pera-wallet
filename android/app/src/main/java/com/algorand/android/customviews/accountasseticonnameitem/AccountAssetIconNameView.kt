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

package com.algorand.android.customviews.accountasseticonnameitem

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
import com.algorand.android.R
import com.algorand.android.customviews.accountasseticonnameitem.model.AccountAssetIconNameConfiguration
import com.algorand.android.databinding.ItemAccountAssetIconNameBinding
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding

class AccountAssetIconNameView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(ItemAccountAssetIconNameBinding::inflate)

    fun initWithConfiguration(configuration: AccountAssetIconNameConfiguration) {
        with(configuration) {
            setStartAccountIconResource(accountIconDrawablePreview)
            setStartIconResId?.let { setStartIconResource(it) }
            startSmallIconDrawable?.let { setStartSmallIconDrawable(it) }
            startSmallIconResId?.let { setStartSmallIconDrawableResource(it) }
            titleEndIconDrawable?.let { setTrailingIconOfTitleText(it) }
            titleEndIconResId?.let { setTrailingIconOfTitleText(it) }
            title?.let { setTitleText(it) }
            titleResId?.let { setTitleText(it) }
            titleTextColorResId?.let { setTitleTextColor(it) }
            description?.let { setDescriptionText(it) }
            descriptionResId?.let { setDescriptionText(it) }
        }
    }

    fun getStartIconImageView(): AppCompatImageView = binding.startIconImageView

    private fun setStartAccountIconResource(accountIconDrawablePreview: AccountIconDrawablePreview) {
        binding.startIconImageView.apply {
            setImageDrawable(
                AccountIconDrawable.create(
                    context = context,
                    accountIconDrawablePreview = accountIconDrawablePreview,
                    sizeResId = R.dimen.spacing_xxxxlarge
                )
            )
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

    fun setTitleText(@StringRes titleResId: Int) {
        binding.titleTextView.setText(titleResId)
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
}
