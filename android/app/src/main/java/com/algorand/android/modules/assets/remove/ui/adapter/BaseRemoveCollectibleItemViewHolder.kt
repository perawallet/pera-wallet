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
import com.algorand.android.databinding.ItemRemoveCollectibleBinding
import com.algorand.android.models.BaseRemoveAssetItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemovableItem.BaseRemoveCollectibleItem
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

abstract class BaseRemoveCollectibleItemViewHolder(
    private val binding: ItemRemoveCollectibleBinding,
    private val listener: CollectibleRemovalItemListener
) : BaseViewHolder<BaseRemoveAssetItem>(binding.root) {

    override fun bind(item: BaseRemoveAssetItem) {
        if (item !is BaseRemoveCollectibleItem) return
        with(binding.collectibleStatefulItemView) {
            with(item) {
                bindImage(baseAssetDrawableProvider = baseAssetDrawableProvider)
                setTitleText(title = name.getName(resources))
                setDescriptionText(description = shortName.getName(resources))
                setPrimaryValueText(primaryValue = formattedCompactAmount)
                setSecondaryValueText(secondaryValue = formattedSelectedCurrencyCompactValue)
                setButtonState(state = actionItemButtonState)
                setClickListeners(removeCollectibleListItem = this)
            }
        }
    }

    private fun bindImage(baseAssetDrawableProvider: BaseAssetDrawableProvider) {
        binding.collectibleStatefulItemView.apply {
            getStartIconImageView().apply {
                baseAssetDrawableProvider.provideAssetDrawable(
                    imageView = this,
                    onResourceFailed = ::setStartIconDrawable
                )
            }
        }
    }

    private fun setClickListeners(removeCollectibleListItem: BaseRemoveCollectibleItem) {
        with(binding.collectibleStatefulItemView) {
            setOnClickListener { listener.onItemClick(removeCollectibleListItem.id) }
            setActionButtonClickListener { listener.onActionButtonClick(removeCollectibleListItem) }
        }
    }

    interface CollectibleRemovalItemListener {
        fun onActionButtonClick(removeAssetListItem: BaseRemoveCollectibleItem)
        fun onItemClick(collectibleId: Long)
    }

    protected interface RemoveCollectibleItemViewHolderCreator {
        fun create(parent: ViewGroup, listener: CollectibleRemovalItemListener): BaseRemoveCollectibleItemViewHolder
    }

    companion object {
        fun createItemRemoveCollectibleBinding(parent: ViewGroup): ItemRemoveCollectibleBinding {
            return ItemRemoveCollectibleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        }
    }
}
