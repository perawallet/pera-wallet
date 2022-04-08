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

package com.algorand.android.nft.ui.nfsdetail

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.IMAGE
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.UNSUPPORTED
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.VIDEO

class CollectibleMediaAdapter(
    private val listener: MediaClickListener
) : ListAdapter<BaseCollectibleMediaItem, BaseViewHolder<BaseCollectibleMediaItem>>(BaseDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseCollectibleMediaItem> {
        return when (viewType) {
            IMAGE.ordinal -> createImageMediaViewHolder(parent)
            VIDEO.ordinal -> createVideMediaViewHolder(parent)
            UNSUPPORTED.ordinal -> createUnsupportedMediaViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag : Unknown view type")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseCollectibleMediaItem>, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createImageMediaViewHolder(parent: ViewGroup): CollectibleImageMediaViewHolder {
        return CollectibleImageMediaViewHolder.create(parent)
    }

    private fun createVideMediaViewHolder(parent: ViewGroup): CollectibleVideoMediaViewHolder {
        return CollectibleVideoMediaViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    listener.onVideoMediaClick(getItem(bindingAdapterPosition).downloadUrl)
                }
            }
        }
    }

    private fun createUnsupportedMediaViewHolder(parent: ViewGroup): CollectibleUnsupportedMediaViewHolder {
        return CollectibleUnsupportedMediaViewHolder.create(parent)
    }

    interface MediaClickListener {
        fun onVideoMediaClick(videoUrl: String?)
    }

    companion object {
        private val logTag = CollectibleMediaAdapter::class.java.simpleName
    }
}
