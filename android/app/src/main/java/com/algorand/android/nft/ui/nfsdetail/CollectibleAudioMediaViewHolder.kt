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

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.algorand.android.databinding.ItemCollectibleAudioMediaBinding
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.utils.loadImage

class CollectibleAudioMediaViewHolder(
    private val binding: ItemCollectibleAudioMediaBinding,
    private val listener: CollectibleAudioMediaViewHolderListener
) : BaseCollectibleMediaViewHolder(binding.root) {

    override fun bind(item: BaseCollectibleMediaItem) {
        if (item !is BaseCollectibleMediaItem.AudioCollectibleMediaItem) return
        with(binding.collectibleAudioCollectibleImageView) {
            setOnClickListener { listener.onAudioClick(item.previewUrl, this) }
            context.loadImage(
                item.previewUrl.orEmpty(),
                onResourceReady = ::showImage,
                onLoadFailed = { showText(item.errorText) }
            ).also { showVideoPlayButton() }
        }
    }

    fun interface CollectibleAudioMediaViewHolderListener {
        fun onAudioClick(imageUrl: String?, collectibleImageView: View)
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: CollectibleAudioMediaViewHolderListener
        ): CollectibleAudioMediaViewHolder {
            val binding = ItemCollectibleAudioMediaBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return CollectibleAudioMediaViewHolder(binding, listener)
        }
    }
}
