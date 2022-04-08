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

package com.algorand.android.ui.addasset.adapter

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.ASSET_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_IMAGE_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_MIXED_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_NOT_SUPPORTED_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_VIDEO_ITEM
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchImageItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchMixedItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchNotSupportedItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchVideoItemViewHolder
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder

class AssetSearchAdapter(
    private val onAssetClick: (baseAsset: BaseAssetSearchListItem) -> Unit
) : PagingDataAdapter<BaseAssetSearchListItem, BaseViewHolder<BaseAssetSearchListItem>>(BaseDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position)?.itemType?.ordinal ?: RecyclerView.NO_POSITION
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseAssetSearchListItem> {
        return when (viewType) {
            ASSET_ITEM.ordinal -> createAssetSearchItemViewHolder(parent)
            COLLECTIBLE_IMAGE_ITEM.ordinal -> createImageItemImageViewHolder(parent)
            COLLECTIBLE_NOT_SUPPORTED_ITEM.ordinal -> createNotSupportedItemViewHolder(parent)
            COLLECTIBLE_VIDEO_ITEM.ordinal -> createVideoItemViewHolder(parent)
            COLLECTIBLE_MIXED_ITEM.ordinal -> createMixedItemViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag: Unknown viewType = $viewType")
        }
    }

    private fun createAssetSearchItemViewHolder(parent: ViewGroup): AssetSearchItemViewHolder {
        return AssetSearchItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition)?.let { assetSearchItem -> onAssetClick(assetSearchItem) }
                }
            }
        }
    }

    private fun createImageItemImageViewHolder(parent: ViewGroup): CollectibleSearchImageItemViewHolder {
        return CollectibleSearchImageItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition)?.let { assetSearchItem -> onAssetClick(assetSearchItem) }
                }
            }
        }
    }

    private fun createVideoItemViewHolder(parent: ViewGroup): CollectibleSearchVideoItemViewHolder {
        return CollectibleSearchVideoItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition)?.let { assetSearchItem -> onAssetClick(assetSearchItem) }
                }
            }
        }
    }

    private fun createMixedItemViewHolder(parent: ViewGroup): CollectibleSearchMixedItemViewHolder {
        return CollectibleSearchMixedItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition)?.let { assetSearchItem -> onAssetClick(assetSearchItem) }
                }
            }
        }
    }

    private fun createNotSupportedItemViewHolder(parent: ViewGroup): CollectibleSearchNotSupportedItemViewHolder {
        return CollectibleSearchNotSupportedItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition)?.let { assetSearchItem -> onAssetClick(assetSearchItem) }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAssetSearchListItem>, position: Int) {
        getItem(position)?.let { assetQueryItem ->
            holder.bind(assetQueryItem)
        }
    }

    companion object {
        private val logTag = AssetSearchAdapter::class.java.simpleName
    }
}
