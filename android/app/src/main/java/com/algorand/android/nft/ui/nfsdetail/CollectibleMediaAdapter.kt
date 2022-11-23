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

import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.AUDIO
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.GIF
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.IMAGE
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.NO_MEDIA
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.UNSUPPORTED
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType.VIDEO
import com.algorand.android.nft.ui.nfsdetail.CollectibleAudioMediaViewHolder.CollectibleAudioMediaViewHolderListener
import com.algorand.android.nft.ui.nfsdetail.CollectibleGifMediaViewHolder.CollectibleGifMediaViewHolderListener
import com.algorand.android.nft.ui.nfsdetail.CollectibleImageMediaViewHolder.CollectibleImageMediaViewHolderListener
import com.algorand.android.nft.ui.nfsdetail.CollectibleVideoMediaViewHolder.CollectibleVideoMediaViewHolderListener

class CollectibleMediaAdapter(
    private val listener: MediaClickListener
) : ListAdapter<BaseCollectibleMediaItem, BaseViewHolder<BaseCollectibleMediaItem>>(BaseDiffUtil()) {

    private val imageClickListener =
        CollectibleImageMediaViewHolderListener { imageUrl, errorDisplayText, imageView, mediaType, previewPrismUrl ->
            listener.onImageMediaClick(imageUrl, errorDisplayText, imageView, mediaType, previewPrismUrl)
        }

    private val videoClickListener = CollectibleVideoMediaViewHolderListener { imageUrl, collectibleImageView ->
        listener.onVideoMediaClick(imageUrl, collectibleImageView)
    }

    private val audioClickListener = CollectibleAudioMediaViewHolderListener { imageUrl, collectibleImageView ->
        listener.onAudioMediaClick(imageUrl, collectibleImageView)
    }

    private val gifClickListener =
        CollectibleGifMediaViewHolderListener { imageUrl, errorText, collectibleImageView, mediaType, previewPrismUrl ->
            listener.onGifMediaClick(imageUrl, errorText, collectibleImageView, mediaType, previewPrismUrl)
        }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseCollectibleMediaItem> {
        return when (viewType) {
            IMAGE.ordinal -> createImageMediaViewHolder(parent)
            VIDEO.ordinal -> createVideoMediaViewHolder(parent)
            UNSUPPORTED.ordinal -> createUnsupportedMediaViewHolder(parent)
            GIF.ordinal -> createGifMediaViewHolder(parent)
            NO_MEDIA.ordinal -> createNoMediaViewHolder(parent)
            AUDIO.ordinal -> createAudioMediaViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag : Unknown view type")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseCollectibleMediaItem>, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createImageMediaViewHolder(parent: ViewGroup): CollectibleImageMediaViewHolder {
        return CollectibleImageMediaViewHolder.create(parent, imageClickListener)
    }

    private fun createVideoMediaViewHolder(parent: ViewGroup): CollectibleVideoMediaViewHolder {
        return CollectibleVideoMediaViewHolder.create(parent, videoClickListener)
    }

    private fun createUnsupportedMediaViewHolder(parent: ViewGroup): CollectibleUnsupportedMediaViewHolder {
        return CollectibleUnsupportedMediaViewHolder.create(parent)
    }

    private fun createNoMediaViewHolder(parent: ViewGroup): CollectibleNoMediaViewHolder {
        return CollectibleNoMediaViewHolder.create(parent)
    }

    private fun createGifMediaViewHolder(parent: ViewGroup): CollectibleGifMediaViewHolder {
        return CollectibleGifMediaViewHolder.create(parent, gifClickListener)
    }

    private fun createAudioMediaViewHolder(parent: ViewGroup): CollectibleAudioMediaViewHolder {
        return CollectibleAudioMediaViewHolder.create(parent, audioClickListener)
    }

    interface MediaClickListener {
        fun onVideoMediaClick(videoUrl: String?, collectibleImageView: View)
        fun onAudioMediaClick(audioUrl: String?, collectibleImageView: View)
        fun onImageMediaClick(
            imageUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: BaseCollectibleMediaItem.ItemType,
            previewPrismUrl: String
        )

        fun onGifMediaClick(
            previewUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: BaseCollectibleMediaItem.ItemType,
            previewPrismUrl: String
        )
    }

    companion object {
        private val logTag = CollectibleMediaAdapter::class.java.simpleName
    }
}
