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

package com.algorand.android.modules.basefoundaccount.information.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemFoundAccountInformationAssetBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basefoundaccount.information.ui.model.BaseFoundAccountInformationItem

class FoundAccountInformationAssetViewHolder(
    private val binding: ItemFoundAccountInformationAssetBinding,
    private val listener: Listener
) : BaseViewHolder<BaseFoundAccountInformationItem>(binding.root) {

    override fun bind(item: BaseFoundAccountInformationItem) {
        if (item !is BaseFoundAccountInformationItem.AssetItem) return
        with(item) {
            with(binding.assetItemView) {
                getStartIconImageView().apply {
                    baseAssetDrawableProvider.provideAssetDrawable(
                        imageView = this,
                        onResourceFailed = ::setStartIconDrawable
                    )
                }
                setTitleText(name.getName(resources))
                setDescriptionText(shortName.getName(resources))
                setPrimaryValueText(formattedPrimaryValue)
                setSecondaryValueText(formattedSecondaryValue)
                setTitleTextColor(verificationTierConfiguration.textColorResId)
                setTrailingIconOfTitleText(verificationTierConfiguration.drawableResId)
                setOnLongClickListener { listener.onAssetItemLongClick(assetId); true }
            }
        }
    }

    fun interface Listener {
        fun onAssetItemLongClick(assetId: Long)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): FoundAccountInformationAssetViewHolder {
            val binding = ItemFoundAccountInformationAssetBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return FoundAccountInformationAssetViewHolder(binding, listener)
        }
    }
}
