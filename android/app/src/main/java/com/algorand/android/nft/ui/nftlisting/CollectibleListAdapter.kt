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

package com.algorand.android.nft.ui.nftlisting

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.BaseCollectibleItem
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.GIF_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.IMAGE_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.MIXED_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.NOT_SUPPORTED_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.PENDING_ADDITION_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.PENDING_REMOVAL_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.PENDING_SENDING_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.RECEIVE_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.SOUND_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.VIDEO_ITEM
import com.algorand.android.nft.ui.nftlisting.viewholder.BaseCollectibleListViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.CollectibleImageViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.CollectibleMixedViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.CollectibleNotSupportedViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.CollectiblePendingAdditionViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.CollectiblePendingRemovalViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.CollectiblePendingSendingViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.NftGifViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.NftSoundViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.NftVideoViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.ReceiveNftViewHolder

class CollectibleListAdapter(
    private val listener: CollectibleListAdapterListener
) : ListAdapter<BaseCollectibleListItem, RecyclerView.ViewHolder>(BaseDiffUtil<BaseCollectibleListItem>()) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            IMAGE_ITEM.ordinal -> createImageViewHolder(parent)
            SOUND_ITEM.ordinal -> createSoundViewHolder(parent)
            VIDEO_ITEM.ordinal -> createVideoViewHolder(parent)
            GIF_ITEM.ordinal -> createGifViewHolder(parent)
            RECEIVE_ITEM.ordinal -> createReceiveViewHolder(parent)
            NOT_SUPPORTED_ITEM.ordinal -> createNotSupportedViewHolder(parent)
            PENDING_ADDITION_ITEM.ordinal -> createPendingAdditionViewHolder(parent)
            PENDING_REMOVAL_ITEM.ordinal -> createPendingRemovalViewHolder(parent)
            PENDING_SENDING_ITEM.ordinal -> createPendingSendingViewHolder(parent)
            MIXED_ITEM.ordinal -> createMixedViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag: Unknown Item Type -> $viewType")
        }
    }

    private fun createImageViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return CollectibleImageViewHolder.create(parent).apply {
            setNftItemClickListener(this) { nftItem ->
                listener.onImageItemClick(nftItem.collectibleId, nftItem.optedInAccountAddress)
            }
        }
    }

    private fun createSoundViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return NftSoundViewHolder.create(parent).apply {
            setNftItemClickListener(this) { nftItem ->
                listener.onSoundItemClick(nftItem.collectibleId, nftItem.optedInAccountAddress)
            }
        }
    }

    private fun createVideoViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return NftVideoViewHolder.create(parent).apply {
            setNftItemClickListener(this) { nftItem ->
                listener.onVideoItemClick(nftItem.collectibleId, nftItem.optedInAccountAddress)
            }
        }
    }

    private fun createGifViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return NftGifViewHolder.create(parent).apply {
            setNftItemClickListener(this) { nftItem ->
                listener.onGifItemClick(nftItem.collectibleId, nftItem.optedInAccountAddress)
            }
        }
    }

    private fun createNotSupportedViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return CollectibleNotSupportedViewHolder.create(parent).apply {
            setNftItemClickListener(this) { nftItem ->
                listener.onNotSupportedItemClick(nftItem.collectibleId, nftItem.optedInAccountAddress)
            }
        }
    }

    private fun createReceiveViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return ReceiveNftViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    listener.onReceiveCollectibleClick()
                }
            }
        }
    }

    private fun createPendingAdditionViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return CollectiblePendingAdditionViewHolder.create(parent)
    }

    private fun createPendingRemovalViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return CollectiblePendingRemovalViewHolder.create(parent)
    }

    private fun createPendingSendingViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return CollectiblePendingSendingViewHolder.create(parent)
    }

    private fun createMixedViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return CollectibleMixedViewHolder.create(parent).apply {
            setNftItemClickListener(this) { nftItem ->
                listener.onMixedItemClick(nftItem.collectibleId, nftItem.optedInAccountAddress)
            }
        }
    }

    private fun setNftItemClickListener(
        viewHolder: RecyclerView.ViewHolder,
        clickAction: (BaseCollectibleItem) -> Unit
    ) {
        with(viewHolder) {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    clickAction(getItem(bindingAdapterPosition) as BaseCollectibleItem)
                }
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is BaseCollectibleListViewHolder) holder.bind(getItem(position) as BaseCollectibleItem)
    }

    interface CollectibleListAdapterListener {
        fun onVideoItemClick(collectibleAssetId: Long, publicKey: String)
        fun onImageItemClick(collectibleAssetId: Long, publicKey: String)
        fun onSoundItemClick(collectibleAssetId: Long, publicKey: String)
        fun onGifItemClick(collectibleAssetId: Long, publicKey: String)
        fun onNotSupportedItemClick(collectibleAssetId: Long, publicKey: String)
        fun onMixedItemClick(collectibleAssetId: Long, publicKey: String)
        fun onReceiveCollectibleClick()
    }

    companion object {
        private val logTag = CollectibleListAdapter::class.java.simpleName
    }
}
