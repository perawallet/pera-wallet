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

package com.algorand.android.ui.send.assetselection.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.doOnLayout
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.databinding.ItemSendAssetSelectionBinding
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

class SelectAssetItemViewHolder(
    private val binding: ItemSendAssetSelectionBinding,
    private val listener: SelectAssetItemListener
) : BaseViewHolder<BaseSelectAssetItem>(binding.root) {

    override fun bind(item: BaseSelectAssetItem) {
        if (item !is BaseSelectAssetItem.SelectAssetItem) return
        binding.assetItemView.apply {
            with(item.assetItemConfiguration) {
                setAssetStartIconDrawable(
                    assetDrawableProvider = assetIconDrawableProvider,
                    assetName = primaryAssetName,
                    prismUrl = prismUrl
                )
                setAssetTitleText(primaryAssetName?.getName(resources))
                setAssetDescriptionText(secondaryAssetName?.getName(resources))
                setAssetPrimaryValue(primaryValueText)
                setAssetSecondaryValue(secondaryValueText)
                setOnClickListener { listener.onAssetItemClick(assetId) }
                setAssetVerificationTier(verificationTierConfiguration)
            }
        }
    }

    private fun setAssetStartIconDrawable(
        assetDrawableProvider: BaseAssetDrawableProvider?,
        assetName: AssetName?,
        prismUrl: String?
    ) {
        if (assetName == null) return
        with(binding.assetItemView) {
            setStartIconDrawable(drawable = null, forceShow = true)
            getStartIconImageView().doOnLayout {
                assetDrawableProvider?.provideAssetDrawable(
                    context = context,
                    assetName = assetName,
                    logoUri = prismUrl,
                    width = it.measuredWidth,
                    onResourceReady = ::setStartIconDrawable
                )
            }
        }
    }

    private fun setAssetTitleText(assetTitleText: String?) {
        binding.assetItemView.setTitleText(assetTitleText)
    }

    private fun setAssetDescriptionText(assetDescriptionText: String?) {
        binding.assetItemView.setDescriptionText(assetDescriptionText)
    }

    private fun setAssetPrimaryValue(assetPrimaryValue: String?) {
        binding.assetItemView.setPrimaryValueText(assetPrimaryValue)
    }

    private fun setAssetSecondaryValue(assetSecondaryValue: String?) {
        binding.assetItemView.setSecondaryValueText(assetSecondaryValue)
    }

    private fun setAssetVerificationTier(verificationTierConfiguration: VerificationTierConfiguration?) {
        if (verificationTierConfiguration == null) return
        binding.assetItemView.apply {
            setTrailingIconOfTitleText(verificationTierConfiguration.drawableResId)
            setTitleTextColor(verificationTierConfiguration.textColorResId)
        }
    }

    fun interface SelectAssetItemListener {
        fun onAssetItemClick(assetId: Long)
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: SelectAssetItemListener
        ): SelectAssetItemViewHolder {
            val binding = ItemSendAssetSelectionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return SelectAssetItemViewHolder(binding, listener)
        }
    }
}
