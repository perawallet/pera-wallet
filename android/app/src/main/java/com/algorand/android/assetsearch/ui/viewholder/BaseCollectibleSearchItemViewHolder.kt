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
import com.algorand.android.R
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.databinding.ItemSearchCollectibleBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

abstract class BaseCollectibleSearchItemViewHolder(
    private val binding: ItemSearchCollectibleBinding,
    private val listener: CollectibleSearchItemListener
) : BaseViewHolder<BaseAssetSearchListItem>(binding.root) {

    protected open fun bindImage(baseAssetDrawableProvider: BaseAssetDrawableProvider) {
        binding.collectibleItemView.apply {
            getStartIconImageView().apply {
                baseAssetDrawableProvider.provideAssetDrawable(
                    imageView = this,
                    onResourceFailed = ::setStartIconDrawable
                )
            }
        }
    }

    override fun bind(item: BaseAssetSearchListItem) {
        if (item !is BaseAssetSearchListItem.AssetListItem.BaseCollectibleSearchListItem) return
        with(binding.collectibleItemView) {
            with(item) {
                setTitleText(fullName.getName(resources))
                bindImage(baseAssetDrawableProvider)
                setAssetDescriptionText(shortName.getName(resources), assetId)
                setButtonState(accountAssetItemButtonState)
                setAssetItemViewClickListeners(this)
            }
        }
    }

    private fun setAssetDescriptionText(assetShortName: String?, assetId: Long) {
        val assetDescriptionText = binding.root.resources.getString(
            R.string.pair_value_format_with_interpunct,
            assetShortName,
            assetId
        )
        binding.collectibleItemView.setDescriptionText(assetDescriptionText)
    }

    private fun setAssetItemViewClickListeners(
        collectibleSearchItem: BaseAssetSearchListItem.AssetListItem.BaseCollectibleSearchListItem
    ) {
        binding.collectibleItemView.apply {
            if (collectibleSearchItem.accountAssetItemButtonState != AccountAssetItemButtonState.PROGRESS) {
                setActionButtonClickListener { listener.onCollectibleItemActionButtonClick(collectibleSearchItem) }
                setOnClickListener { listener.onCollectibleItemClick(collectibleSearchItem.assetId) }
            } else {
                setActionButtonClickListener(null)
                setOnClickListener(null)
            }
        }
    }

    interface CollectibleSearchItemListener {
        fun onCollectibleItemClick(collectibleId: Long)
        fun onCollectibleItemActionButtonClick(
            assetSearchItem: BaseAssetSearchListItem.AssetListItem.BaseCollectibleSearchListItem
        )
    }

    protected interface CollectibleSearchItemViewHolderCreator {
        fun create(parent: ViewGroup, listener: CollectibleSearchItemListener): BaseCollectibleSearchItemViewHolder
    }

    companion object {
        fun createItemSearchCollectibleBinding(parent: ViewGroup): ItemSearchCollectibleBinding {
            return ItemSearchCollectibleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        }
    }
}
