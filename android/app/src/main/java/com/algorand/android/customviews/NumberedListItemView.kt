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
import android.text.method.MovementMethod
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomNumberedListItemViewBinding
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.viewbinding.viewBinding

class NumberedListItemView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomNumberedListItemViewBinding::inflate)

    init {
        initAttributes(attrs)
    }

    fun setTitleText(text: CharSequence) {
        binding.titleTextView.text = text
    }

    fun setDescriptionText(text: CharSequence) {
        binding.descriptionTextView.text = text
    }

    fun setDescriptionMovementMethod(movementMethod: MovementMethod) {
        binding.descriptionTextView.movementMethod = movementMethod
    }

    fun setDescriptionHighlightColor(color: Int) {
        binding.descriptionTextView.highlightColor = color
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.NumberedListItemView).use {
            it.getString(R.styleable.NumberedListItemView_title)?.let { safeTitle ->
                binding.titleTextView.setTextAndVisibility(safeTitle)
            }
            it.getResourceId(
                R.styleable.NumberedListItemView_titleTextAppearance,
                R.style.TextAppearance_Body_Sans
            ).let { textAppearance ->
                binding.titleTextView.setTextAppearance(textAppearance)
            }
            it.getColor(
                R.styleable.NumberedListItemView_titleTextColor,
                ContextCompat.getColor(context, R.color.text_main)
            ).let { textColor ->
                binding.titleTextView.setTextColor(textColor)
            }

            it.getString(R.styleable.NumberedListItemView_description)?.let { safeDescription ->
                binding.descriptionTextView.setTextAndVisibility(safeDescription)
            }
            it.getResourceId(
                R.styleable.NumberedListItemView_descriptionTextAppearance,
                R.style.TextAppearance_Body_Sans
            ).let { textAppearance ->
                binding.descriptionTextView.setTextAppearance(textAppearance)
            }
            it.getColor(
                R.styleable.NumberedListItemView_descriptionTextColor,
                ContextCompat.getColor(context, R.color.text_gray)
            ).let { textColor ->
                binding.descriptionTextView.setTextColor(textColor)
            }

            it.getString(R.styleable.NumberedListItemView_numeratorText)?.let { safeNumeratorText ->
                binding.iconLabelTextView.setTextAndVisibility(safeNumeratorText)
            }
            it.getResourceId(
                R.styleable.NumberedListItemView_numeratorBackground,
                R.drawable.bg_asset_avatar_border
            ).let { backgroundResId ->
                binding.iconLabelTextView.setBackgroundResource(backgroundResId)
            }
        }
    }
}
