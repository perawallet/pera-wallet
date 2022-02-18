/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.view.Gravity
import android.widget.LinearLayout
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomScreenStateViewBinding
import com.algorand.android.models.ScreenState
import com.algorand.android.utils.extensions.setImageResAndVisibility
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.viewbinding.viewBinding

class ScreenStateView @JvmOverloads constructor(
    context: Context,
    private val attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomScreenStateViewBinding::inflate)

    private val screenState = ScreenState.CustomState()

    init {
        loadAttrs()
        gravity = Gravity.CENTER_HORIZONTAL
        orientation = VERTICAL
    }

    private fun loadAttrs() {
        context?.obtainStyledAttributes(attrs, R.styleable.ScreenStateView)?.use { attrs ->
            screenState.icon = attrs.getResourceId(R.styleable.ScreenStateView_iconRes, -1)
            screenState.title = attrs.getResourceId(R.styleable.ScreenStateView_titleRes, -1)
            screenState.description = attrs.getResourceId(R.styleable.ScreenStateView_descriptionRes, -1)
            screenState.buttonText = attrs.getResourceId(R.styleable.ScreenStateView_buttonTextRes, -1)
        }
        setupUi(screenState)
    }

    fun setOnNeutralButtonClickListener(onClick: () -> Unit) {
        binding.neutralButton.setOnClickListener { onClick() }
    }

    fun clearNeutralButtonClickListener() {
        binding.neutralButton.setOnClickListener(null)
    }

    fun setupUi(screenState: ScreenState) {
        with(binding) {
            with(screenState) {
                infoIconImageView.setImageResAndVisibility(icon)
                titleTextView.setTextAndVisibility(title)
                descriptionTextView.setTextAndVisibility(description)
                neutralButton.setTextAndVisibility(buttonText)
            }
        }
    }
}
