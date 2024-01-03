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

package com.algorand.android.modules.assets.profile.about.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemAssetAboutAssetDescriptionBinding
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem

class AssetAboutAssetDescriptionViewHolder(
    private val binding: ItemAssetAboutAssetDescriptionBinding
) : BaseAssetAboutAssetDescriptionViewHolder(binding) {

    override fun bind(item: BaseAssetAboutListItem) {
        if (item !is BaseAssetAboutListItem.BaseAssetDescriptionItem.AssetDescriptionItem) return
        binding.descriptionTextView.text = item.descriptionText
        super.bind(item)
    }

    companion object : BaseAssetAboutAssetDescriptionViewHolderItemViewHolderCreator {
        override fun create(parent: ViewGroup): AssetAboutAssetDescriptionViewHolder {
            val binding =
                ItemAssetAboutAssetDescriptionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AssetAboutAssetDescriptionViewHolder(binding)
        }
    }
}
