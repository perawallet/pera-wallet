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

package com.algorand.android.modules.assets.remove.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.doOnLayout
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.databinding.ItemRemoveAssetBinding
import com.algorand.android.models.BaseRemoveAssetItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemovableItem.RemoveAssetItem
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

class RemoveAssetItemViewHolder(
    private val binding: ItemRemoveAssetBinding,
    private val listener: AssetRemovalItemListener
) : BaseViewHolder<BaseRemoveAssetItem>(binding.root) {

    override fun bind(item: BaseRemoveAssetItem) {
        if (item !is RemoveAssetItem) return
        with(item) {
            setActionButtonState(actionItemButtonState)
            setAssetStartIconDrawable(
                assetDrawableProvider = baseAssetDrawableProvider,
                assetName = name,
                prismUrl = prismUrl
            )
            setAssetTitleText(name.getName(binding.root.resources))
            setAssetDescriptionText(shortName.getName(binding.root.resources))
            setAssetPrimaryValue(formattedCompactAmount)
            setAssetSecondaryValue(formattedSelectedCurrencyCompactValue, isAmountInSelectedCurrencyVisible)
            setAssetVerificationTier(verificationTierConfiguration)
            setClickListeners(this)
        }
    }

    private fun setAssetStartIconDrawable(
        assetDrawableProvider: BaseAssetDrawableProvider?,
        assetName: AssetName,
        prismUrl: String?
    ) {
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

    private fun setAssetSecondaryValue(assetSecondaryValue: String?, isAmountInSelectedCurrencyVisible: Boolean) {
        if (isAmountInSelectedCurrencyVisible) {
            binding.assetItemView.setSecondaryValueText(assetSecondaryValue)
        }
    }

    private fun setAssetVerificationTier(verificationTierConfiguration: VerificationTierConfiguration) {
        binding.assetItemView.apply {
            setTitleTextColor(verificationTierConfiguration.textColorResId)
            setTrailingIconOfTitleText(verificationTierConfiguration.drawableResId)
        }
    }

    private fun setClickListeners(removeAssetListItem: RemoveAssetItem) {
        with(binding.assetItemView) {
            setOnClickListener { listener.onItemClick(removeAssetListItem.id) }
            setActionButtonClickListener { listener.onActionButtonClick(removeAssetListItem) }
        }
    }

    private fun setActionButtonState(actionItemButtonState: AccountAssetItemButtonState) {
        binding.assetItemView.setButtonState(actionItemButtonState)
    }

    interface AssetRemovalItemListener {
        fun onActionButtonClick(removeAssetListItem: RemoveAssetItem)
        fun onItemClick(assetId: Long)
    }

    companion object {
        fun create(parent: ViewGroup, listener: AssetRemovalItemListener): RemoveAssetItemViewHolder {
            val binding = ItemRemoveAssetBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return RemoveAssetItemViewHolder(binding, listener)
        }
    }
}
