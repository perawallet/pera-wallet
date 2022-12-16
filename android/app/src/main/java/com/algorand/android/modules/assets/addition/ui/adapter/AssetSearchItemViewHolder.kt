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

package com.algorand.android.modules.assets.addition.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.doOnLayout
import com.algorand.android.R
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration.Companion.DEFAULT_TEXT_COLOR_RES_ID
import com.algorand.android.databinding.ItemSearchAssetBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

class AssetSearchItemViewHolder(
    private val binding: ItemSearchAssetBinding,
    private val listener: AssetSearchItemListener
) : BaseViewHolder<BaseAssetSearchListItem>(binding.root) {

    override fun bind(item: BaseAssetSearchListItem) {
        if (item !is BaseAssetSearchListItem.AssetListItem.AssetSearchItem) return
        with(item) {
            setAssetButtonState(accountAssetItemButtonState)
            setAssetStartIconDrawable(
                assetDrawableProvider = baseAssetDrawableProvider,
                assetName = fullName,
                prismUrl = prismUrl
            )
            setAssetTitleText(fullName.getName(binding.root.resources))
            setAssetDescriptionText(shortName.getName(binding.root.resources), assetId)
            setAssetVerificationTier(verificationTierConfiguration)
            setAssetItemViewClickListeners(this)
        }
    }

    private fun setAssetStartIconDrawable(
        assetDrawableProvider: BaseAssetDrawableProvider?,
        assetName: AssetName?,
        prismUrl: String?
    ) {
        if (assetName == null) return
        with(binding.statefulAssetItemView) {
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

    private fun setAssetButtonState(buttonState: AccountAssetItemButtonState) {
        binding.statefulAssetItemView.setButtonState(buttonState)
    }

    private fun setAssetItemViewClickListeners(assetSearchItem: BaseAssetSearchListItem.AssetListItem.AssetSearchItem) {
        binding.statefulAssetItemView.apply {
            if (assetSearchItem.accountAssetItemButtonState != AccountAssetItemButtonState.PROGRESS) {
                setActionButtonClickListener { listener.onAssetItemActionButtonClick(assetSearchItem) }
                setOnClickListener { listener.onAssetItemClick(assetSearchItem.assetId) }
            } else {
                setActionButtonClickListener(null)
                setOnClickListener(null)
            }
        }
    }

    interface AssetSearchItemListener {
        fun onAssetItemClick(assetId: Long)
        fun onAssetItemActionButtonClick(assetSearchItem: BaseAssetSearchListItem.AssetListItem.AssetSearchItem)
    }

    companion object {
        fun create(parent: ViewGroup, listener: AssetSearchItemListener): AssetSearchItemViewHolder {
            val binding = ItemSearchAssetBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AssetSearchItemViewHolder(binding, listener)
        }
    }
}
