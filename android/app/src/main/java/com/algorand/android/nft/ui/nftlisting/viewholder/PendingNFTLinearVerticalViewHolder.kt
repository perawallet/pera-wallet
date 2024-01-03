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

package com.algorand.android.nft.ui.nftlisting.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.algorand.android.databinding.ItemNftVerticalLinearListBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.nft.ui.model.BaseCollectibleListItem

class PendingNFTLinearVerticalViewHolder(
    private val binding: ItemNftVerticalLinearListBinding,
) : BaseViewHolder<BaseCollectibleListItem>(binding.root) {

    override fun bind(item: BaseCollectibleListItem) {
        if (item !is BaseCollectibleListItem.BaseCollectibleItem.BasePendingNFTItem) return
        with(item) {
            with(binding) {
                setStartIconProgressBarVisibility(true)
                setNftNameText(collectibleName?.getName(root.resources))
                setNftCollectionNameText(collectionName)
            }
        }
    }

    private fun setNftNameText(nftName: String?) {
        binding.nftNameTextView.apply {
            isVisible = !nftName.isNullOrBlank()
            text = nftName
        }
    }

    private fun setNftCollectionNameText(collectionName: String?) {
        binding.nftCollectionTextView.apply {
            isVisible = !collectionName.isNullOrBlank()
            text = collectionName
        }
    }

    private fun setStartIconProgressBarVisibility(isVisible: Boolean) {
        binding.nftStartIconProgressBar.isVisible = isVisible
    }

    companion object {
        fun create(parent: ViewGroup): PendingNFTLinearVerticalViewHolder {
            val binding = ItemNftVerticalLinearListBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return PendingNFTLinearVerticalViewHolder(binding)
        }
    }
}
