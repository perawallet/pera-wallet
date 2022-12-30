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

package com.algorand.android.discover.home.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration.Companion.DEFAULT_TEXT_COLOR_RES_ID
import com.algorand.android.databinding.ItemSearchAssetBinding
import com.algorand.android.discover.home.ui.model.DiscoverAssetItem
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

class DiscoverAssetItemViewHolder(
    private val binding: ItemSearchAssetBinding,
    private val listener: DiscoverAssetSearchItemListener
) : BaseViewHolder<DiscoverAssetItem>(binding.root) {

    override fun bind(item: DiscoverAssetItem) {
        with(item) {
            setAssetStartIconDrawable(
                assetDrawableProvider = baseAssetDrawableProvider,
                assetName = fullName
            )
            setAssetTitleText(fullName.getName(binding.root.resources))
            setAssetDescriptionText(shortName.getName(binding.root.resources), assetId)
            setAssetVerificationTier(verificationTierConfiguration)
            setAssetItemViewClickListeners(this)
            formattedUsdValue?.let {
                setAssetPriceText(it)
            }
        }
    }

    private fun setAssetStartIconDrawable(assetDrawableProvider: BaseAssetDrawableProvider?, assetName: AssetName?) {
        with(binding.statefulAssetItemView) {
            if (assetName == null) return
            assetDrawableProvider?.provideAssetDrawable(
                imageView = getStartIconImageView(),
                onResourceFailed = ::setStartIconDrawable
            )
        }
    }

    private fun setAssetTitleText(assetTitleText: String?) {
        binding.statefulAssetItemView.setTitleText(assetTitleText)
    }

    private fun setAssetDescriptionText(assetShortName: String?, assetId: Long) {
        val assetDescriptionText = binding.root.resources.getString(
            R.string.pair_value_format_with_interpunct,
            assetShortName,
            assetId
        )
        binding.statefulAssetItemView.setDescriptionText(assetDescriptionText)
    }

    private fun setAssetVerificationTier(verificationTierConfiguration: VerificationTierConfiguration?) {
        binding.statefulAssetItemView.apply {
            setTitleTextColor(verificationTierConfiguration?.textColorResId ?: DEFAULT_TEXT_COLOR_RES_ID)
            setTrailingIconOfTitleText(verificationTierConfiguration?.drawableResId)
        }
    }

    private fun setAssetPriceText(usdValue: String?) {
        binding.statefulAssetItemView.apply {
            setSecondaryValueText(usdValue)
            setSecondaryValueTextColor(R.color.text_main)
        }
    }

    private fun setAssetItemViewClickListeners(assetSearchItem: DiscoverAssetItem) {
        binding.statefulAssetItemView.setOnClickListener { listener.onAssetItemClick(assetSearchItem.assetId) }
    }

    interface DiscoverAssetSearchItemListener {
        fun onAssetItemClick(assetId: Long)
    }

    companion object {
        fun create(parent: ViewGroup, listener: DiscoverAssetSearchItemListener): DiscoverAssetItemViewHolder {
            val binding = ItemSearchAssetBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return DiscoverAssetItemViewHolder(binding, listener)
        }
    }
}
