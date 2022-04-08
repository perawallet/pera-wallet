/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.addasset.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.databinding.ItemSearchAssetBinding
import com.algorand.android.models.BaseViewHolder

class AssetSearchItemViewHolder(
    private val binding: ItemSearchAssetBinding
) : BaseViewHolder<BaseAssetSearchListItem>(binding.root) {

    override fun bind(item: BaseAssetSearchListItem) {
        with(binding) {
            nameTextView.setupUI(
                showVerified = item.isVerified,
                shortName = item.shortName.getName(root.resources),
                fullName = item.fullName.getName(root.resources),
                assetId = item.assetId,
                isAlgorand = false
            )
            idTextView.text = item.assetId.toString()
        }
    }

    companion object {
        fun create(parent: ViewGroup): AssetSearchItemViewHolder {
            val binding = ItemSearchAssetBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AssetSearchItemViewHolder(binding)
        }
    }
}
