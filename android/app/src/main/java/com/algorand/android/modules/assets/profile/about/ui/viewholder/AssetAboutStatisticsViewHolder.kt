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

package com.algorand.android.modules.assets.profile.about.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintLayout.LayoutParams.PARENT_ID
import androidx.core.view.isVisible
import androidx.core.view.updateLayoutParams
import com.algorand.android.databinding.ItemAssetAboutStatisticsBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem

class AssetAboutStatisticsViewHolder(
    private val binding: ItemAssetAboutStatisticsBinding,
    private val listener: AssetAboutStatisticsListener
) : BaseViewHolder<BaseAssetAboutListItem>(binding.root) {

    override fun bind(item: BaseAssetAboutListItem) {
        if (item !is BaseAssetAboutListItem.StatisticsItem) return
        with(binding) {
            priceTextView.text = item.formattedPriceText
            totalSupplyTextView.text = item.formattedCompactTotalSupplyText
            totalSupplyInfoImageView.setOnClickListener { listener.onTotalSupplyInfoClick() }
            statisticsGroup.isVisible = item.hasPriceInfo
            updateTotalSupplyLabelConstraintSetAccordingPriceInfo(item.hasPriceInfo)
        }
    }

    private fun updateTotalSupplyLabelConstraintSetAccordingPriceInfo(hasPriceInfo: Boolean) {
        with(binding) {
            totalSupplyLabelTextView.updateLayoutParams<ConstraintLayout.LayoutParams> {
                startToStart = if (hasPriceInfo) labelGuideline.id else PARENT_ID
            }
        }
    }

    fun interface AssetAboutStatisticsListener {
        fun onTotalSupplyInfoClick()
    }

    companion object {
        fun create(parent: ViewGroup, listener: AssetAboutStatisticsListener): AssetAboutStatisticsViewHolder {
            val binding = ItemAssetAboutStatisticsBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AssetAboutStatisticsViewHolder(binding, listener)
        }
    }
}
