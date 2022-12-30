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

package com.algorand.android.modules.collectibles.detail.base.ui.viewpager

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.algorand.android.databinding.ItemNftMediaBinding
import com.algorand.android.modules.collectibles.detail.base.ui.model.BaseCollectibleMediaItem
import com.algorand.android.modules.collectibles.detail.base.ui.viewpager.BaseCollectibleMediaViewHolder.NFTMediaDrawableListener

class CollectibleImageMediaViewHolder(
    private val binding: ItemNftMediaBinding,
    private val listener: Listener
) : BaseCollectibleMediaViewHolder(binding, listener) {

    private val nftMediaDrawableListener = NFTMediaDrawableListener { baseAssetDrawableProvider, uri ->
        val clickListener = {
            listener.onImageMediaClick(
                mediaUri = baseAssetDrawableProvider.logoUri,
                cachedMediaUri = uri,
                collectibleImageView = binding.nftMediaImageView
            )
        }
        with(binding) {
            fullScreenImageView.setOnClickListener { clickListener.invoke() }
            nftMediaImageView.setOnClickListener { clickListener.invoke() }
        }
    }

    override fun bind(item: BaseCollectibleMediaItem) {
        super.bind(item)
        if (item !is BaseCollectibleMediaItem.ImageCollectibleMediaItem) return
        setNFTMediaDrawableListener(nftMediaDrawableListener)
        with(binding) {
            nftMediaImageView.transitionName = nftMediaImageView.id.toString()
            fullScreenImageView.isVisible = item.hasFullScreenSupport
        }
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): CollectibleImageMediaViewHolder {
            val binding = ItemNftMediaBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return CollectibleImageMediaViewHolder(binding, listener)
        }
    }
}
