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

package com.algorand.android.ui.send.assetselection.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.customviews.CollectibleImageView
import com.algorand.android.databinding.ItemSelectCollectibleBinding
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.utils.PrismUrlBuilder

abstract class BaseSelectCollectibleItemViewHolder(
    val binding: ItemSelectCollectibleBinding
) : RecyclerView.ViewHolder(binding.root) {

    protected open fun bindImage(
        collectibleImageView: CollectibleImageView,
        item: BaseSelectAssetItem.BaseSelectCollectibleItem
    ) {
        with(collectibleImageView) {
            showText(item.avatarDisplayText.getAsAvatarNameOrDefault(resources))
        }
    }

    fun bind(item: BaseSelectAssetItem.BaseSelectCollectibleItem) {
        with(item) {
            with(binding) {
                mainTextView.text = name
                subTextView.text = shortName
                verifiedImageView.isVisible = isVerified
                assetBalanceTextView.text = formattedCompactAmount
                assetBalanceInCurrencyTextView.isVisible = isAmountInSelectedCurrencyVisible
                assetBalanceInCurrencyTextView.text = formattedSelectedCurrencyCompactValue
                bindImage(collectibleImageView, item)
            }
        }
    }

    protected fun createPrismUrl(url: String, width: Int): String {
        return PrismUrlBuilder.create(url)
            .addWidth(width)
            .addQuality(PrismUrlBuilder.DEFAULT_IMAGE_QUALITY)
            .build()
    }

    protected interface SelectCollectibleItemViewHolderCreator {
        fun create(parent: ViewGroup): BaseSelectCollectibleItemViewHolder
    }

    companion object {
        fun createItemSelectCollectibleBinding(parent: ViewGroup): ItemSelectCollectibleBinding {
            return ItemSelectCollectibleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        }
    }
}
