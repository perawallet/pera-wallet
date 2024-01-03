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

class CollectibleVideoMediaViewHolder(
    private val binding: ItemNftMediaBinding,
    private val listener: Listener
) : BaseCollectibleMediaViewHolder(binding, listener) {

    override fun bind(item: BaseCollectibleMediaItem) {
        super.bind(item)
        if (item !is BaseCollectibleMediaItem.VideoCollectibleMediaItem) return
        with(binding) {
            with(fullScreenImageView) {
                setOnClickListener { listener.onVideoMediaClick(item.previewUrl ?: item.downloadUrl) }
                isVisible = item.hasFullScreenSupport
            }
            nftMediaImageView.setOnClickListener { listener.onVideoMediaClick(item.previewUrl ?: item.downloadUrl) }
        }
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): CollectibleVideoMediaViewHolder {
            val binding = ItemNftMediaBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return CollectibleVideoMediaViewHolder(binding, listener)
        }
    }
}
