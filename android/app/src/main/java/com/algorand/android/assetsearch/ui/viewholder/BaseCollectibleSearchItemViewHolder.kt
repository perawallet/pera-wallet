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

package com.algorand.android.assetsearch.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.customviews.CollectibleImageView
import com.algorand.android.databinding.ItemSearchCollectibleBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.utils.PrismUrlBuilder

abstract class BaseCollectibleSearchItemViewHolder(
    private val binding: ItemSearchCollectibleBinding
) : BaseViewHolder<BaseAssetSearchListItem>(binding.root) {

    protected open fun bindImage(collectibleImageView: CollectibleImageView, item: BaseAssetSearchListItem) {
        with(collectibleImageView) {
            showText(item.avatarDisplayText.getAsAvatarNameOrDefault(resources))
        }
    }

    override fun bind(item: BaseAssetSearchListItem) {
        with(binding) {
            mainTextView.text = item.fullName.getName(root.resources)
            subTextView.text = item.shortName.getName(root.resources)
            collectibleIdTextView.text = item.assetId.toString()
            verifiedImageView.isVisible = item.isVerified
            bindImage(collectibleImageView, item)
        }
    }

    protected fun createPrismUrl(url: String, width: Int): String {
        return PrismUrlBuilder.create(url)
            .addWidth(width)
            .addQuality(PrismUrlBuilder.DEFAULT_IMAGE_QUALITY)
            .build()
    }

    protected interface CollectibleSearchItemViewHolderCreator {
        fun create(parent: ViewGroup): BaseCollectibleSearchItemViewHolder
    }

    companion object {
        fun createItemSearchCollectibleBinding(parent: ViewGroup): ItemSearchCollectibleBinding {
            return ItemSearchCollectibleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        }
    }
}
