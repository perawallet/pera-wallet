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
import androidx.core.view.doOnLayout
import com.algorand.android.databinding.ItemCollectibleGifMediaBinding
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType
import com.algorand.android.utils.createPrismUrl
import com.algorand.android.utils.loadGif

class CollectibleGifMediaViewHolder(
    private val binding: ItemCollectibleGifMediaBinding,
    private val listener: CollectibleGifMediaViewHolderListener
) : BaseCollectibleMediaViewHolder(binding.root) {

    override fun bind(item: BaseCollectibleMediaItem) {
        if (item !is BaseCollectibleMediaItem.GifCollectibleMediaItem) return
        with(binding.collectibleGifCollectibleImageView) {
            doOnLayout {
                with(getImageView() ?: return@doOnLayout) {
                    val previewPrismUrl = createPrismUrl(item.previewUrl.orEmpty(), measuredWidth)
                    transitionName = id.toString()
                    setOnClickListener {
                        listener.onGifMediaClick(
                            previewUrl = item.previewUrl,
                            errorText = item.errorText,
                            collectibleImageView = this,
                            mediaType = item.itemType,
                            previewPrismUrl = previewPrismUrl
                        )
                    }
                    loadGif(
                        uri = previewPrismUrl,
                        onResourceReady = { gifDrawable ->
                            showImage(gifDrawable)
                            gifDrawable.start()
                        },
                        onLoadFailed = { showText(item.errorText) }
                    )
                }
            }
        }
    }

    fun interface CollectibleGifMediaViewHolderListener {
        fun onGifMediaClick(
            previewUrl: String?,
            errorText: String,
            collectibleImageView: View,
            mediaType: ItemType,
            previewPrismUrl: String
        )
    }

    companion object {
        fun create(parent: ViewGroup, listener: CollectibleGifMediaViewHolderListener): CollectibleGifMediaViewHolder {
            val binding = ItemCollectibleGifMediaBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return CollectibleGifMediaViewHolder(binding, listener)
        }
    }
}
