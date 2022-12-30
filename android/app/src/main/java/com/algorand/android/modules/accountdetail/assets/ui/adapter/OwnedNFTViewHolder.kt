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

package com.algorand.android.modules.accountdetail.assets.ui.adapter

import android.graphics.drawable.Drawable
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.updateLayoutParams
import com.algorand.android.R
import com.algorand.android.customviews.collectibleimageview.BaseCollectibleImageView.Companion.DECREASED_OPACITY
import com.algorand.android.databinding.ItemNftVerticalLinearListBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem

class OwnedNFTViewHolder(
    private val binding: ItemNftVerticalLinearListBinding,
    private val listener: Listener
) : BaseViewHolder<AccountDetailAssetsItem>(binding.root) {

    override fun bind(item: AccountDetailAssetsItem) {
        if (item !is AccountDetailAssetsItem.BaseAssetItem.BaseOwnedItem.NFTItem) return
        with(item) {
            with(binding) {
                nftStartIconImageView.apply {
                    setOpacity(shouldDecreaseOpacity)
                    baseAssetDrawableProvider.provideAssetDrawable(
                        imageView = this,
                        onResourceFailed = ::setStartIconDrawable
                    )
                }
                setStartSmallIconDrawable(nftIndicatorDrawable?.toDrawable(root.context, true))
                setNftCollectionNameText(collectionName)
                setNftAmountText(formattedAmount, isAmountVisible)
                setNftNameText(name.getName(root.resources))
                root.setOnClickListener { listener.onOwnedNFTItemClick(id) }
                root.setOnLongClickListener { listener.onOwnedNFTItemLongPressed(id); true }
            }
        }
    }

    private fun setOpacity(decreaseOpacity: Boolean = false) {
        binding.nftStartIconImageView.alpha = if (decreaseOpacity) DECREASED_OPACITY else 1f
    }

    private fun setStartIconDrawable(drawable: Drawable?) {
        binding.nftStartIconImageView.apply {
            isVisible = drawable != null
            setImageDrawable(drawable)
        }
    }

    private fun setStartSmallIconDrawable(drawable: Drawable?) {
        binding.nftStartSmallIconImageView.apply {
            isVisible = drawable != null
            setImageDrawable(drawable)
        }
    }

    private fun setNftNameText(nftName: String?) {
        with(binding) {
            nftNameTextView.apply {
                isVisible = !nftName.isNullOrBlank()
                text = nftName
                updateLayoutParams<ConstraintLayout.LayoutParams> {
                    when {
                        nftCollectionTextView.isVisible -> bottomToTop = nftCollectionTextView.id
                        nftAmountTextView.isVisible -> bottomToTop = nftAmountTextView.id
                        else -> bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID
                    }
                }
            }
        }
    }

    private fun setNftCollectionNameText(collectionName: String?) {
        binding.nftCollectionTextView.apply {
            isVisible = !collectionName.isNullOrBlank()
            text = collectionName
        }
    }

    private fun setNftAmountText(amount: String?, amountVisible: Boolean) {
        binding.nftAmountTextView.apply {
            isVisible = !amount.isNullOrBlank() && amountVisible
            text = if (amountVisible) {
                StringBuilder().apply {
                    if (binding.nftCollectionTextView.isVisible) {
                        append(resources.getString(R.string.interpunct))
                    }
                    append(resources.getString(R.string.asset_amount_with_x, amount))
                }
            } else {
                null
            }
        }
    }

    interface Listener {
        fun onOwnedNFTItemClick(nftId: Long)
        fun onOwnedNFTItemLongPressed(nftId: Long)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): OwnedNFTViewHolder {
            val binding = ItemNftVerticalLinearListBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return OwnedNFTViewHolder(binding, listener)
        }
    }
}
