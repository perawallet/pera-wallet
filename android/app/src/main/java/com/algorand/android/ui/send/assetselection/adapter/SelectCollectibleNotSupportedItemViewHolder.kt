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
import com.algorand.android.customviews.CollectibleImageView
import com.algorand.android.databinding.ItemSelectCollectibleBinding
import com.algorand.android.models.BaseSelectAssetItem

class SelectCollectibleNotSupportedItemViewHolder(
    binding: ItemSelectCollectibleBinding
) : BaseSelectCollectibleItemViewHolder(binding) {

    override fun bindImage(
        collectibleImageView: CollectibleImageView,
        item: BaseSelectAssetItem.BaseSelectCollectibleItem
    ) {
        super.bindImage(collectibleImageView, item)
        if (item is BaseSelectAssetItem.BaseSelectCollectibleItem.SelectNotSupportedCollectibleItem) {
            with(collectibleImageView) {
                showText(item.avatarDisplayText.getAsAvatarNameOrDefault(resources))
            }
        }
    }

    companion object : SelectCollectibleItemViewHolderCreator {
        override fun create(parent: ViewGroup): SelectCollectibleNotSupportedItemViewHolder {
            return SelectCollectibleNotSupportedItemViewHolder(createItemSelectCollectibleBinding(parent))
        }
    }
}
