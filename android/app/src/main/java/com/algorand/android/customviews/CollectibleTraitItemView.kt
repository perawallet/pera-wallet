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
 */

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import com.algorand.android.R
import com.algorand.android.databinding.CustomCollectiblePropertyViewBinding
import com.algorand.android.nft.ui.model.CollectibleTraitItem
import com.algorand.android.utils.viewbinding.viewBinding

class CollectibleTraitItemView(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomCollectiblePropertyViewBinding::inflate)

    init {
        orientation = VERTICAL
        initRootView()
    }

    private fun setTrait(collectibleTraitItem: CollectibleTraitItem) {
        with(binding) {
            propertyTitle.text = collectibleTraitItem.title
            propertyDescription.text = collectibleTraitItem.description
        }
    }

    private fun initRootView() {
        setBackgroundResource(R.drawable.bg_algo_rewards_border)

        val horizontalPadding = resources.getDimensionPixelSize(R.dimen.spacing_normal)
        val verticalPadding = resources.getDimensionPixelSize(R.dimen.spacing_xsmall)
        setPadding(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding)

        val marginTop = resources.getDimensionPixelSize(R.dimen.spacing_small)
        val marginEnd = resources.getDimensionPixelSize(R.dimen.spacing_small)
        layoutParams = LayoutParams(LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)).apply {
            setMargins(leftMargin, marginTop, marginEnd, bottomMargin)
        }
    }

    companion object {
        fun create(
            context: Context,
            collectibleTraitItem: CollectibleTraitItem
        ): CollectibleTraitItemView {
            return CollectibleTraitItemView(context).apply {
                setTrait(collectibleTraitItem)
            }
        }
    }
}
