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
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.customviews.collectibleimageview.BaseCollectibleImageView.Companion.DECREASED_OPACITY
import com.algorand.android.databinding.ItemBaseCollectibleListBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.utils.NFTItemClickListener
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.nftindicatordrawable.BaseNFTIndicatorDrawable

open class OwnedNFTGridViewHolder(
    protected val binding: ItemBaseCollectibleListBinding,
    private val listener: NFTItemClickListener?
) : BaseViewHolder<BaseCollectibleListItem>(binding.root) {

    override fun bind(item: BaseCollectibleListItem) {
        if (item !is BaseCollectibleListItem.BaseCollectibleItem) return
        binding.root.setOnClickListener { listener?.onNFTClick(item.collectibleId, item.optedInAccountAddress) }
        initCollectionName(item.collectionName)
        initNFTName(item.collectibleName)
        initNFTAmount(item.isAmountVisible, item.formattedCollectibleAmount)
        loadNFTDrawable(item)
        loadNFTIndicatorDrawable(item.nftIndicatorDrawable)
    }

    private fun initNFTAmount(isAmountVisible: Boolean, formattedCollectibleAmount: String?) {
        with(binding.collectibleAmountTextView) {
            if (isAmountVisible) {
                text = resources.getString(R.string.asset_amount_with_x, formattedCollectibleAmount)
                show()
            } else {
                hide()
            }
        }
    }

    private fun initCollectionName(collectionName: String?) {
        binding.collectionTextView.apply {
            text = collectionName
            isVisible = collectionName.isNullOrBlank().not()
        }
    }

    private fun initNFTName(collectibleName: AssetName?) {
        binding.nameTextView.apply {
            text = collectibleName?.getName(resources)
            isVisible = collectibleName?.getName().isNullOrBlank().not()
        }
    }

    private fun loadNFTDrawable(item: BaseCollectibleListItem.BaseCollectibleItem) {
        binding.collectibleImageView.run {
            setOpacity(item.shouldDecreaseOpacity)
            item.baseAssetDrawableProvider.provideAssetDrawable(
                imageView = this,
                onResourceFailed = ::setImageDrawable
            )
        }
    }

    private fun setOpacity(decreaseOpacity: Boolean = false) {
        binding.collectibleImageView.alpha = if (decreaseOpacity) DECREASED_OPACITY else 1f
    }

    private fun loadNFTIndicatorDrawable(nftIndicatorDrawable: BaseNFTIndicatorDrawable?) {
        binding.warningImageView.apply {
            setImageDrawable(nftIndicatorDrawable?.toDrawable(context = context, showBackground = true))
            isVisible = nftIndicatorDrawable != null
        }
    }

    companion object {
        fun create(parent: ViewGroup, listener: NFTItemClickListener): OwnedNFTGridViewHolder {
            val binding = ItemBaseCollectibleListBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return OwnedNFTGridViewHolder(binding, listener)
        }
    }
}
