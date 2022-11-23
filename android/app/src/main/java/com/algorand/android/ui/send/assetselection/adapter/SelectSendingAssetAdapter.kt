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

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_ASSET_TEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_AUDIO_ITEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_IMAGE_ITEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_MIXED_ITEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM
import com.algorand.android.models.BaseSelectAssetItem.ItemType.SELECT_COLLECTIBLE_VIDEO_ITEM
import com.algorand.android.models.BaseViewHolder

class SelectSendingAssetAdapter(onAssetClick: (Long) -> Unit) :
    ListAdapter<BaseSelectAssetItem, BaseViewHolder<BaseSelectAssetItem>>(BaseDiffUtil()) {

    private val assetListener = SelectAssetItemViewHolder.SelectAssetItemListener(onAssetClick)
    private val collectibleListener = BaseSelectCollectibleItemViewHolder.SelectCollectibleItemListener(onAssetClick)

    override fun getItemViewType(position: Int): Int {
        return getItem(position)?.itemType?.ordinal ?: RecyclerView.NO_POSITION
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseSelectAssetItem> {
        return when (viewType) {
            SELECT_ASSET_TEM.ordinal -> createAssetItemViewHolder(parent)
            SELECT_COLLECTIBLE_IMAGE_ITEM.ordinal -> createCollectibleImageItemViewHolder(parent)
            SELECT_COLLECTIBLE_VIDEO_ITEM.ordinal -> createCollectibleVideoItemViewHolder(parent)
            SELECT_COLLECTIBLE_AUDIO_ITEM.ordinal -> createCollectibleAudioItemViewHolder(parent)
            SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM.ordinal -> createCollectibleNotSupportedItemViewHolder(parent)
            SELECT_COLLECTIBLE_MIXED_ITEM.ordinal -> createCollectibleMixedItemViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag : Unknown viewType = $viewType")
        }
    }

    private fun createAssetItemViewHolder(parent: ViewGroup): SelectAssetItemViewHolder {
        return SelectAssetItemViewHolder.create(parent, assetListener)
    }

    private fun createCollectibleImageItemViewHolder(parent: ViewGroup): SelectCollectableImageItemViewHolder {
        return SelectCollectableImageItemViewHolder.create(parent, collectibleListener)
    }

    private fun createCollectibleVideoItemViewHolder(parent: ViewGroup): SelectCollectibleVideoItemViewHolder {
        return SelectCollectibleVideoItemViewHolder.create(parent, collectibleListener)
    }

    private fun createCollectibleAudioItemViewHolder(parent: ViewGroup): SelectCollectibleAudioItemViewHolder {
        return SelectCollectibleAudioItemViewHolder.create(parent, collectibleListener)
    }

    private fun createCollectibleMixedItemViewHolder(parent: ViewGroup): SelectCollectibleMixedItemViewHolder {
        return SelectCollectibleMixedItemViewHolder.create(parent, collectibleListener)
    }

    private fun createCollectibleNotSupportedItemViewHolder(
        parent: ViewGroup
    ): SelectCollectibleNotSupportedItemViewHolder {
        return SelectCollectibleNotSupportedItemViewHolder.create(parent, collectibleListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseSelectAssetItem>, position: Int) {
        holder.bind(getItem(position))
    }

    companion object {
        private val logTag = SelectSendingAssetAdapter::class.java.simpleName
    }
}
