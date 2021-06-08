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
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.annotation.DrawableRes
import com.algorand.android.R
import com.algorand.android.databinding.ItemAssetBalanceViewBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.formatAmount

class AssetBalanceLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    init {
        orientation = VERTICAL
    }

    fun addAssetBalanceView(
        assetInformation: AssetInformation,
        @DrawableRes dividerDrawableResId: Int = R.drawable.horizontal_divider,
        addDividerToTop: Boolean = true
    ) {
        if (addDividerToTop) {
            addView(ImageView(context).apply {
                layoutParams = LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
                setImageResource(dividerDrawableResId)
            })
        }

        addView(
            ItemAssetBalanceViewBinding.inflate(LayoutInflater.from(context), this, false).apply {
                assetNameTextView.setupUI(assetInformation)
                val formattedAmount = assetInformation.amount.formatAmount(assetInformation.decimals)
                balanceTextView.text = formattedAmount
            }.root
        )
    }
}
