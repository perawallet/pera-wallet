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
import android.view.Gravity.CENTER
import android.widget.LinearLayout
import androidx.core.content.res.getResourceIdOrThrow
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomEmptyListViewBinding
import com.algorand.android.utils.viewbinding.viewBinding

class EmptyListView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomEmptyListViewBinding::inflate)

    init {
        gravity = CENTER
        orientation = VERTICAL
        initAttributes(attrs)
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.EmptyListView).use {
            binding.imageView.setImageResource(it.getResourceIdOrThrow(R.styleable.EmptyListView_emptyImageSrc))
            binding.titleTextView.text = it.getText(R.styleable.EmptyListView_emptyTitleText)
            binding.descriptionTextView.text = it.getText(R.styleable.EmptyListView_emptyDescriptionText)
        }
    }
}
