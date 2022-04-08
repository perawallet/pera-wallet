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

package com.algorand.android.ui.send.assetselection.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectCollectibleImageItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectMixedCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectNotSupportedCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectVideoCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_ASSET_TEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_IMAGE_ITEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_MIXED_ITEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_VIDEO_ITEM
import com.algorand.android.models.BaseSelectAssetItem.SelectAssetItem

class SelectSendingAssetAdapter(
    private val onAssetClick: (Long) -> Unit
) : ListAdapter<BaseSelectAssetItem, RecyclerView.ViewHolder>(BaseDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position)?.itemType?.ordinal ?: RecyclerView.NO_POSITION
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            SELECT_ASSET_TEM.ordinal -> createAssetItemViewHolder(parent)
            SELECT_COLLECTIBLE_IMAGE_ITEM.ordinal -> createCollectibleImageItemViewHolder(parent)
            SELECT_COLLECTIBLE_VIDEO_ITEM.ordinal -> createCollectibleVideoItemViewHolder(parent)
            SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM.ordinal -> createCollectibleNotSupportedItemViewHolder(parent)
            SELECT_COLLECTIBLE_MIXED_ITEM.ordinal -> createCollectibleMixedItemViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag : Unknown viewType = $viewType")
        }
    }

    private fun createAssetItemViewHolder(parent: ViewGroup): SelectAssetItemViewHolder {
        return SelectAssetItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition).id.let(onAssetClick)
                }
            }
        }
    }

    private fun createCollectibleImageItemViewHolder(parent: ViewGroup): SelectCollectableImageItemViewHolder {
        return SelectCollectableImageItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition).id.let(onAssetClick)
                }
            }
        }
    }

    private fun createCollectibleVideoItemViewHolder(parent: ViewGroup): SelectCollectibleVideoItemViewHolder {
        return SelectCollectibleVideoItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition).id.let(onAssetClick)
                }
            }
        }
    }

    private fun createCollectibleMixedItemViewHolder(parent: ViewGroup): SelectCollectibleMixedItemViewHolder {
        return SelectCollectibleMixedItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition).id.let(onAssetClick)
                }
            }
        }
    }

    private fun createCollectibleNotSupportedItemViewHolder(
        parent: ViewGroup
    ): SelectCollectibleNotSupportedItemViewHolder {
        return SelectCollectibleNotSupportedItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition).id.let(onAssetClick)
                }
            }
        }
    }

    override fun onBindViewHolder(holderSelect: RecyclerView.ViewHolder, position: Int) {
        when (holderSelect) {
            is SelectAssetItemViewHolder -> {
                holderSelect.bind(getItem(position) as SelectAssetItem)
            }
            is SelectCollectibleNotSupportedItemViewHolder -> {
                holderSelect.bind(getItem(position) as SelectNotSupportedCollectibleItem)
            }
            is SelectCollectibleVideoItemViewHolder -> {
                holderSelect.bind(getItem(position) as SelectVideoCollectibleItem)
            }
            is SelectCollectableImageItemViewHolder -> {
                holderSelect.bind(getItem(position) as SelectCollectibleImageItem)
            }
            is SelectCollectibleMixedItemViewHolder -> {
                holderSelect.bind(getItem(position) as SelectMixedCollectibleItem)
            }
            else -> throw IllegalArgumentException("$logTag : Item View Type is Unknown.")
        }
    }

    companion object {
        private val logTag = SelectSendingAssetAdapter::class.java.simpleName
    }
}
