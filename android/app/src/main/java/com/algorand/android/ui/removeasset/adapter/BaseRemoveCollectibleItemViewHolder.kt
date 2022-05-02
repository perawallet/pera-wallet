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

package com.algorand.android.ui.removeasset.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.customviews.CollectibleImageView
import com.algorand.android.databinding.ItemRemoveCollectibleBinding
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem
import com.algorand.android.utils.PrismUrlBuilder

abstract class BaseRemoveCollectibleItemViewHolder(
    val binding: ItemRemoveCollectibleBinding
) : RecyclerView.ViewHolder(binding.root) {

    protected open fun bindImage(collectibleImageView: CollectibleImageView, item: BaseRemoveCollectibleItem) {
        with(collectibleImageView) {
            showText(item.avatarDisplayText.getAsAvatarNameOrDefault(resources))
        }
    }

    fun bind(baseRemoveAssetItem: BaseRemoveCollectibleItem) {
        with(baseRemoveAssetItem) {
            with(binding) {
                mainTextView.text = name
                subTextView.text = shortName
                verifiedImageView.isVisible = isVerified
                assetBalanceTextView.text = formattedCompactAmount
                // TODO: 2.03.2022 Move these logics into domain layer
                assetBalanceInCurrencyTextView.text =
                    if (isAmountInSelectedCurrencyVisible) {
                        formattedSelectedCurrencyCompactValue
                    } else {
                        root.resources.getString(notAvailableResId)
                    }
                bindImage(collectibleImageView, baseRemoveAssetItem)
            }
        }
    }

    protected fun createPrismUrl(url: String, width: Int): String {
        return PrismUrlBuilder.create(url)
            .addWidth(width)
            .addQuality(PrismUrlBuilder.DEFAULT_IMAGE_QUALITY)
            .build()
    }

    protected interface RemoveCollectibleItemViewHolderCreator {
        fun create(parent: ViewGroup): BaseRemoveCollectibleItemViewHolder
    }

    companion object {

        fun createItemRemoveCollectibleBinding(parent: ViewGroup): ItemRemoveCollectibleBinding {
            return ItemRemoveCollectibleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        }
    }
}
