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

package com.algorand.android.ui.accountselection

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountSelectionBinding
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.toShortenedAddress

class LedgerAccountSelectionViewHolder(
    val binding: ItemAccountSelectionBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(accountSelectionListItem: AccountSelectionListItem) {
        with(accountSelectionListItem) {
            binding.nameTextView.apply {
                text = account.address.toShortenedAddress()
                setDrawable(start = AppCompatResources.getDrawable(context, accountImageResource))
            }

            val algoInformation = assetInformationList.first()

            binding.algoAssetNameTextView.setupUI(algoInformation)
            binding.algoBalanceTextView.text = algoInformation.amount.formatAsAlgoString()

            setupAssetCount(assetInformationList.count() - 1) // -1 added because algo is included here

            bindSelection(isSelected)
        }
    }

    private fun setupAssetCount(assetCount: Int) {
        // remove all views
        if (assetCount == 0) {
            binding.assetCountGroup.visibility = View.GONE
        } else {
            binding.assetCountTextView.text =
                itemView.resources.getQuantityString(R.plurals.asset_count, assetCount, assetCount)
            binding.assetCountGroup.visibility = View.VISIBLE
        }
    }

    fun bindSelection(isSelected: Boolean) {
        if (isSelected) {
            binding.parentLayout.setBackgroundResource(SELECTED_ITEM_BACKGROUND)
        } else {
            binding.parentLayout.background = null
        }

        binding.headerIconView.isSelected = isSelected
    }

    companion object {
        private const val SELECTED_ITEM_BACKGROUND = R.drawable.bg_selected_ledger_account

        fun create(
            parent: ViewGroup,
            searchType: SearchType
        ): LedgerAccountSelectionViewHolder {
            val binding = ItemAccountSelectionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LedgerAccountSelectionViewHolder(binding).apply {
                if (searchType == SearchType.REGISTER) {
                    binding.headerIconView.setImageResource(R.drawable.checkbox_selector)
                } else {
                    binding.headerIconView.setImageResource(R.drawable.radio_selector)
                }
            }
        }
    }
}
