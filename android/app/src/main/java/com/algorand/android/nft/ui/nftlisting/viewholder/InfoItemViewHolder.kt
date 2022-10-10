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
import com.algorand.android.R
import com.algorand.android.databinding.ItemBaseCollectiblesInfoItemBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.nft.ui.model.BaseCollectibleListItem

class InfoItemViewHolder(
    private val binding: ItemBaseCollectiblesInfoItemBinding,
    private val infoItemListener: InfoItemListener
) : BaseViewHolder<BaseCollectibleListItem>(binding.root) {

    override fun bind(item: BaseCollectibleListItem) {
        if (item !is BaseCollectibleListItem.InfoViewItem) return
        with(binding.root) {
            setTitle(
                resources.getQuantityString(
                    R.plurals.collectible_count,
                    item.displayedCollectibleCount,
                    item.displayedCollectibleCount,
                )
            )
            setPrimaryButtonClickListener { infoItemListener.primaryButtonOnClickListener() }
            setSecondaryButtonClickListener { infoItemListener.secondaryButtonClickListener() }
            setSecondaryButtonVisibility(item.isAddButtonVisible)
            isVisible = item.isVisible
        }
    }

    interface InfoItemListener {
        fun primaryButtonOnClickListener()
        fun secondaryButtonClickListener()
    }

    companion object {
        fun create(parent: ViewGroup, infoItemListener: InfoItemListener): InfoItemViewHolder {
            val binding = ItemBaseCollectiblesInfoItemBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return InfoItemViewHolder(binding, infoItemListener = infoItemListener)
        }
    }
}
