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
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomListMenuItemViewBinding
import com.algorand.android.utils.extensions.setImageResAndVisibility
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.viewbinding.viewBinding

class ListMenuItemView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomListMenuItemViewBinding::inflate)

    init {
        initAttributes(attrs)
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.ListMenuItemView).use {
            val title = it.getString(R.styleable.ListMenuItemView_title)
            val description = it.getString(R.styleable.ListMenuItemView_description)
            val iconResId = it.getResourceId(R.styleable.ListMenuItemView_icon, -1)
            val isDividerVisible = it.getBoolean(R.styleable.ListMenuItemView_showBottomDivider, false)

            with(binding) {
                titleTextView.setTextAndVisibility(title)
                descriptionTextView.setTextAndVisibility(description)
                iconImageView.setImageResAndVisibility(iconResId)
                dividerView.isVisible = isDividerVisible
            }
        }
    }
}
