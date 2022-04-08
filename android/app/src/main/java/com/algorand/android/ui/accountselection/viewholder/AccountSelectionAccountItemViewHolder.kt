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
 */

package com.algorand.android.ui.accountselection.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountSimpleBinding
import com.algorand.android.models.BaseAccountSelectionListItem

class AccountSelectionAccountItemViewHolder(
    private val binding: ItemAccountSimpleBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: BaseAccountSelectionListItem.BaseAccountItem.AccountItem) {
        with(binding) {
            accountIconImageView.setAccountIcon(item.accountIcon)
            accountDisplayNameTextView.text = item.displayName
            accountHoldingsTextView.isVisible = item.showHoldings
            accountHoldingsTextView.text = item.formattedHoldings
            assetCountTextView.isVisible = item.showAssetCount
            assetCountTextView.text = root.resources.getQuantityString(
                R.plurals.account_asset_count,
                item.assetCount,
                item.assetCount,
                item.assetCount
            )
        }
    }

    companion object {
        fun create(parent: ViewGroup): AccountSelectionAccountItemViewHolder {
            val binding = ItemAccountSimpleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountSelectionAccountItemViewHolder(binding)
        }
    }
}
