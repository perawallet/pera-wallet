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
import com.algorand.android.databinding.ItemCollectibleImageMediaBinding
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem.ItemType
import com.algorand.android.utils.createPrismUrl
import com.algorand.android.utils.loadImage

class CollectibleImageMediaViewHolder(
    private val binding: ItemCollectibleImageMediaBinding,
    private val listener: CollectibleImageMediaViewHolderListener
) : BaseCollectibleMediaViewHolder(binding.root) {

    override fun bind(item: BaseCollectibleMediaItem) {
        if (item !is BaseCollectibleMediaItem.ImageCollectibleMediaItem) return
        with(binding.collectibleImageCollectibleImageView) {
            transitionName = id.toString()
            doOnLayout {
                val previewPrismUrl = createPrismUrl(item.previewUrl.orEmpty(), measuredWidth)
                context.loadImage(
                    uri = previewPrismUrl,
                    onResourceReady = { showImage(it) },
                    onLoadFailed = { showText(item.errorText) }
                )
                setOnClickListener {
                    listener.onImageClick(
                        imageUrl = item.previewUrl,
                        errorDisplayText = item.errorText,
                        collectibleImageView = this,
                        mediaType = item.itemType,
                        previewPrismUrl = previewPrismUrl
                    )
                }
            }
        }
    }

    fun interface CollectibleImageMediaViewHolderListener {
        fun onImageClick(
            imageUrl: String?,
            errorDisplayText: String,
            collectibleImageView: View,
            mediaType: ItemType,
            previewPrismUrl: String
        )
    }

    companion object {
        fun create(
            parent: ViewGroup,
            collectibleImageMediaViewHolderListener: CollectibleImageMediaViewHolderListener
        ): CollectibleImageMediaViewHolder {
            val binding = ItemCollectibleImageMediaBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return CollectibleImageMediaViewHolder(binding, collectibleImageMediaViewHolderListener)
        }
    }
}
