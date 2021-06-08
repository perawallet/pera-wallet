/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.common.assetselector

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemAssetSelectionBinding

class AssetSelectorViewHolder(
    private val binding: ItemAssetSelectionBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(assetSelectorItem: AssetSelectorBaseItem.AssetSelectorItem) {
        with(assetSelectorItem.assetInformation) {
            binding.nameTextView.setupUI(this)
            binding.balanceTextView.apply {
                setAmount(amount, decimals, isAlgorand())
            }
        }

        binding.dividerView.isVisible = assetSelectorItem.showDivider
    }

    companion object {
        fun create(parent: ViewGroup): AssetSelectorViewHolder {
            val binding = ItemAssetSelectionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AssetSelectorViewHolder(binding)
        }
    }
}
