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

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseRemoveAssetItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveCollectibleImageItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveCollectibleMixedItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveCollectibleVideoItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveNotSupportedCollectibleItem
import com.algorand.android.models.BaseRemoveAssetItem.ItemType.REMOVE_ASSET_ITEM
import com.algorand.android.models.BaseRemoveAssetItem.ItemType.REMOVE_COLLECTIBLE_IMAGE_ITEM
import com.algorand.android.models.BaseRemoveAssetItem.ItemType.REMOVE_COLLECTIBLE_MIXED_ITEM
import com.algorand.android.models.BaseRemoveAssetItem.ItemType.REMOVE_COLLECTIBLE_NOT_SUPPORTED_ITEM
import com.algorand.android.models.BaseRemoveAssetItem.ItemType.REMOVE_COLLECTIBLE_VIDEO_ITEM
import com.algorand.android.models.BaseRemoveAssetItem.RemoveAssetItem
import com.algorand.android.ui.accountdetail.assets.adapter.AccountAssetsAdapter

class RemoveAssetAdapter(
    private val onRemoveAssetClick: (BaseRemoveAssetItem) -> Unit
) : ListAdapter<BaseRemoveAssetItem, RecyclerView.ViewHolder>(BaseDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position)?.itemType?.ordinal ?: RecyclerView.NO_POSITION
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            REMOVE_ASSET_ITEM.ordinal -> createRemoveAssetItemViewHolder(parent)
            REMOVE_COLLECTIBLE_IMAGE_ITEM.ordinal -> createRemoveCollectibleImageItemViewHolder(parent)
            REMOVE_COLLECTIBLE_NOT_SUPPORTED_ITEM.ordinal -> createRemoveNotSupportedCollectibleItemViewHolder(parent)
            REMOVE_COLLECTIBLE_VIDEO_ITEM.ordinal -> createRemoveCollectibleVideoItemViewHolder(parent)
            REMOVE_COLLECTIBLE_MIXED_ITEM.ordinal -> createRemoveCollectibleMixedItemViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag: Unknown viewType = $viewType")
        }
    }

    private fun createRemoveAssetItemViewHolder(parent: ViewGroup): RemoveAssetItemViewHolder {
        return RemoveAssetItemViewHolder.create(parent).apply {
            binding.removeAssetButton.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    onRemoveAssetClick(getItem(bindingAdapterPosition) as BaseRemoveAssetItem)
                }
            }
        }
    }

    private fun createRemoveNotSupportedCollectibleItemViewHolder(
        parent: ViewGroup
    ): RemoveNotSupportedCollectibleItemViewHolder {
        return RemoveNotSupportedCollectibleItemViewHolder.create(parent).apply {
            binding.removeAssetButton.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    onRemoveAssetClick(getItem(bindingAdapterPosition) as BaseRemoveAssetItem)
                }
            }
        }
    }

    private fun createRemoveCollectibleImageItemViewHolder(parent: ViewGroup): RemoveCollectibleImageItemViewHolder {
        return RemoveCollectibleImageItemViewHolder.create(parent).apply {
            binding.removeAssetButton.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    onRemoveAssetClick(getItem(bindingAdapterPosition) as BaseRemoveAssetItem)
                }
            }
        }
    }

    private fun createRemoveCollectibleMixedItemViewHolder(parent: ViewGroup): RemoveCollectibleMixedItemViewHolder {
        return RemoveCollectibleMixedItemViewHolder.create(parent).apply {
            binding.removeAssetButton.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    onRemoveAssetClick(getItem(bindingAdapterPosition) as BaseRemoveAssetItem)
                }
            }
        }
    }

    private fun createRemoveCollectibleVideoItemViewHolder(parent: ViewGroup): RemoveCollectibleVideoItemViewHolder {
        return RemoveCollectibleVideoItemViewHolder.create(parent).apply {
            binding.removeAssetButton.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    onRemoveAssetClick(getItem(bindingAdapterPosition) as BaseRemoveAssetItem)
                }
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is RemoveAssetItemViewHolder -> holder.bind(getItem(position) as RemoveAssetItem)
            is RemoveCollectibleImageItemViewHolder -> holder.bind(getItem(position) as RemoveCollectibleImageItem)
            is RemoveCollectibleMixedItemViewHolder -> holder.bind(getItem(position) as RemoveCollectibleMixedItem)
            is RemoveCollectibleVideoItemViewHolder -> holder.bind(getItem(position) as RemoveCollectibleVideoItem)
            is RemoveNotSupportedCollectibleItemViewHolder ->
                holder.bind(getItem(position) as RemoveNotSupportedCollectibleItem)
            else -> throw IllegalArgumentException("$logTag : Item View Type is Unknown.")
        }
    }

    companion object {
        private val logTag = AccountAssetsAdapter::class.java.simpleName
    }
}
