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
import android.view.ViewGroup
import com.algorand.android.databinding.ItemCollectibleUnsupportedMediaBinding
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem

class CollectibleUnsupportedMediaViewHolder(
    private val binding: ItemCollectibleUnsupportedMediaBinding
) : BaseCollectibleMediaViewHolder(binding.root) {

    override fun bind(item: BaseCollectibleMediaItem) {
        if (item !is BaseCollectibleMediaItem.UnsupportedCollectibleMediaItem) return
        binding.collectibleUnsupportedCollectibleImageView.showText(item.errorText)
    }

    companion object {
        fun create(parent: ViewGroup): CollectibleUnsupportedMediaViewHolder {
            val binding = ItemCollectibleUnsupportedMediaBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return CollectibleUnsupportedMediaViewHolder(binding)
        }
    }
}
