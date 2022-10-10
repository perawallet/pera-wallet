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
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.ViewGroup
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.isVisible
import androidx.core.view.updateLayoutParams
import com.algorand.android.R
import com.algorand.android.databinding.CustomListConfigurationHeaderBinding
import com.algorand.android.utils.viewbinding.viewBinding

class ListConfigurationHeaderView(context: Context, attrs: AttributeSet? = null) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomListConfigurationHeaderBinding::inflate)

    init {
        initAttributes(attrs)
    }

    fun setPrimaryButtonVisibility(isVisible: Boolean) {
        binding.primaryButton.isVisible = isVisible
    }

    fun setPrimaryButtonClickListener(onClick: () -> Unit) {
        binding.primaryButton.setOnClickListener { onClick() }
    }

    fun setPrimaryButtonState(isActive: Boolean) {
        binding.primaryButton.isActivated = isActive
    }

    fun setSecondaryButtonVisibility(isVisible: Boolean) {
        binding.secondaryButton.isVisible = isVisible
    }

    fun setSecondaryButtonClickListener(onClick: () -> Unit) {
        binding.secondaryButton.setOnClickListener { onClick() }
    }

    fun setTitle(title: String) {
        binding.titleTextView.text = title
    }

    fun setTitle(@StringRes titleResId: Int) {
        binding.titleTextView.setText(titleResId)
    }

    fun setPrimaryButtonIcon(@DrawableRes icon: Int, useIconsOwnTint: Boolean = false) {
        binding.primaryButton.setIconResource(icon)
        if (useIconsOwnTint) {
            binding.primaryButton.iconTint = null
        } else {
            binding.primaryButton.setIconTintResource(PRIMARY_BUTTON_ICON_DEFAULT_TINT)
        }
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context?.obtainStyledAttributes(attrs, R.styleable.ListConfigurationHeaderView)?.use {
            val title = it.getString(R.styleable.ListConfigurationHeaderView_title)
            initTitle(title)

            val primaryButtonText = it.getString(R.styleable.ListConfigurationHeaderView_primaryButtonText)
            val primaryButtonIcon = it.getDrawable(R.styleable.ListConfigurationHeaderView_primaryButtonIcon)
            val isPrimaryButtonActive =
                it.getBoolean(R.styleable.ListConfigurationHeaderView_primaryButtonActive, false)
            initPrimaryButton(primaryButtonText, primaryButtonIcon, isPrimaryButtonActive)

            val secondaryButtonText = it.getString(R.styleable.ListConfigurationHeaderView_secondaryButtonText)
            val secondaryButtonIcon = it.getDrawable(R.styleable.ListConfigurationHeaderView_secondaryButtonIcon)
            initSecondaryButton(secondaryButtonText, secondaryButtonIcon)
        }
    }

    private fun initTitle(title: String?) {
        if (title != null) binding.titleTextView.text = title
    }

    private fun initPrimaryButton(
        primaryButtonText: String?,
        primaryButtonIcon: Drawable?,
        isPrimaryButtonActive: Boolean?
    ) {
        with(binding.primaryButton) {
            isVisible = !primaryButtonText.isNullOrBlank() || primaryButtonIcon != null
            if (!primaryButtonText.isNullOrBlank()) text = primaryButtonText
            if (primaryButtonIcon != null) icon = primaryButtonIcon
            if (isPrimaryButtonActive != null) isActivated = isPrimaryButtonActive
            setIconTintResource(PRIMARY_BUTTON_ICON_DEFAULT_TINT)
        }
    }

    private fun initSecondaryButton(secondaryButtonText: String?, secondaryButtonIcon: Drawable?) {
        with(binding.secondaryButton) {
            isVisible = !secondaryButtonText.isNullOrBlank() || secondaryButtonIcon != null
            if (!secondaryButtonText.isNullOrBlank()) {
                text = secondaryButtonText
                updateLayoutParams {
                    width = ViewGroup.LayoutParams.WRAP_CONTENT
                }
            }
            if (secondaryButtonIcon != null) icon = secondaryButtonIcon
            setIconTintResource(SECONDARY_BUTTON_ICON_DEFAULT_TINT)
        }
    }

    companion object {
        private const val PRIMARY_BUTTON_ICON_DEFAULT_TINT = R.color.positive
        private const val SECONDARY_BUTTON_ICON_DEFAULT_TINT = R.color.positive
    }
}
