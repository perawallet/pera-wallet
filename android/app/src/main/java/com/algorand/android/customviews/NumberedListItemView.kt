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
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomNumberedListItemViewBinding
import com.algorand.android.utils.extensions.setImageResAndVisibility
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

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.NumberedListItemView).use {
            val title = it.getString(R.styleable.NumberedListItemView_title)
            val iconResId = it
                .getResourceId(R.styleable.NumberedListItemView_icon, R.drawable.bg_asset_avatar_border)
            val iconText = it.getString(R.styleable.NumberedListItemView_iconText)

            with(binding) {
                titleTextView.setTextAndVisibility(title)
                iconImageView.setImageResAndVisibility(iconResId)
                iconLabelTextView.setTextAndVisibility(iconText)
            }
        }
    }
}
