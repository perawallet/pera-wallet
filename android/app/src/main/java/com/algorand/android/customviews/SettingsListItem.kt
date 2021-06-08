/*
 * Copyright 2019 Algorand, Inc.
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
import android.util.AttributeSet
import android.view.Gravity.CENTER_VERTICAL
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.res.getResourceIdOrThrow
import androidx.core.content.res.use
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomSettingsListItemBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SettingsListItem @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomSettingsListItemBinding::inflate)

    init {
        setLayoutAttributes()
        initAttributes(attrs)
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.SettingsListItem).use {
            binding.nameTextView.text = it.getText(R.styleable.SettingsListItem_settingsText)
            binding.iconImageView.setImageResource(
                it.getResourceIdOrThrow(R.styleable.SettingsListItem_settingsIcon)
            )
            binding.arrowImageView.isVisible =
                it.getBoolean(R.styleable.SettingsListItem_settingsShowArrow, true)
        }
    }

    private fun setLayoutAttributes() {
        orientation = HORIZONTAL
        gravity = CENTER_VERTICAL
        minimumHeight = resources.getDimensionPixelOffset(R.dimen.settings_list_item_min_height)
        setBackgroundResource(R.drawable.bg_settings_list_item)
        setLayoutPadding()
    }

    private fun setLayoutPadding() {
        val horizontalPadding = resources.getDimensionPixelOffset(R.dimen.settings_list_item_horizontal_padding)
        val verticalPadding = resources.getDimensionPixelOffset(R.dimen.keyline_1_minus_8dp)
        setPadding(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding)
    }

    fun setSecondaryTextView(secondaryText: String) {
        binding.secondaryTextView.apply {
            text = secondaryText
            visibility = View.VISIBLE
        }
    }
}
