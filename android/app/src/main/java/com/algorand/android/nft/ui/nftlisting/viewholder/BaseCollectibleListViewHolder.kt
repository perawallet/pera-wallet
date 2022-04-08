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

package com.algorand.android.nft.ui.nftlisting.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.annotation.DrawableRes
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemBaseCollectibleListBinding
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.utils.PrismUrlBuilder
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show

abstract class BaseCollectibleListViewHolder(
    protected val binding: ItemBaseCollectibleListBinding
) : RecyclerView.ViewHolder(binding.root) {

    open fun bind(item: BaseCollectibleListItem.BaseCollectibleItem) {
        initCollectionAndCollectibleName(item)
        if (!item.isOwnedByTheUser) showWarningIcon(R.drawable.ic_error) else hideWarningIcon()
        showCollectibleBadge(item.badgeImageResId)
    }

    private fun initCollectionAndCollectibleName(nftListItem: BaseCollectibleListItem.BaseCollectibleItem) {
        with(binding) {
            collectionTextView.apply {
                text = nftListItem.collectionName
                isVisible = nftListItem.collectionName.isNullOrBlank().not()
            }
            nameTextView.apply {
                text = nftListItem.collectibleName
                isVisible = nftListItem.collectibleName.isNullOrBlank().not()
            }
        }
    }

    private fun showCollectibleBadge(@DrawableRes badgeImageResId: Int?) {
        binding.collectibleBadgeImageView.apply {
            if (badgeImageResId != null) setImageResource(badgeImageResId)
            isVisible = badgeImageResId != null
        }
    }

    protected fun showWarningIcon(@DrawableRes iconResId: Int) {
        binding.warningImageView.apply {
            setImageResource(iconResId)
            show()
        }
    }

    private fun hideWarningIcon() {
        binding.warningImageView.hide()
    }

    protected fun createPrismUrl(url: String, width: Int): String {
        return PrismUrlBuilder.create(url)
            .addWidth(width)
            .addQuality(PrismUrlBuilder.DEFAULT_IMAGE_QUALITY)
            .build()
    }

    protected interface NftListViewHolderCreator {
        fun create(parent: ViewGroup): BaseCollectibleListViewHolder
    }

    protected companion object {

        private const val IMAGE_WIDTH_QUERY_VALUE = 150

        fun createItemNftListBinding(parent: ViewGroup): ItemBaseCollectibleListBinding {
            return ItemBaseCollectibleListBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        }
    }
}
