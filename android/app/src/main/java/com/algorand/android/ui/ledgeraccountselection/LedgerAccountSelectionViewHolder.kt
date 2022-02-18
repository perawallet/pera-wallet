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

package com.algorand.android.ui.ledgeraccountselection

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountSelectionBinding
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.toShortenedAddress

class LedgerAccountSelectionViewHolder(
    val binding: ItemAccountSelectionBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(accountSelectionListItem: AccountSelectionListItem.AccountItem) {
        with(binding) {
            with(accountSelectionListItem) {
                nameTextView.text = account.address.toShortenedAddress()
                setupAssetCount(assetInformationList.count())
                bindSelection(isSelected)
            }
        }
    }

    // TODO: 6.10.2021 Missing NFT Count
    private fun setupAssetCount(assetCount: Int) {
        with(binding) {
            if (assetCount > 0) {
                assetCountTextView.setTextAndVisibility(
                    root.resources.getQuantityString(R.plurals.asset_count, assetCount, assetCount)
                )
            }
        }
    }

    private fun bindSelection(isSelected: Boolean) {
        with(binding) {
            if (isSelected) {
                parentLayout.setBackgroundResource(SELECTED_ITEM_BACKGROUND)
            } else {
                parentLayout.background = null
            }
            headerIconView.isSelected = isSelected
        }
    }

    companion object {
        private const val SELECTED_ITEM_BACKGROUND = R.drawable.bg_selected_ledger_account

        fun create(parent: ViewGroup, searchType: SearchType): LedgerAccountSelectionViewHolder {
            return with(ItemAccountSelectionBinding.inflate(LayoutInflater.from(parent.context), parent, false)) {
                LedgerAccountSelectionViewHolder(this).apply {
                    if (searchType == SearchType.REGISTER) {
                        headerIconView.setImageResource(R.drawable.checkbox_selector)
                    } else {
                        headerIconView.setImageResource(R.drawable.radio_selector)
                    }
                }
            }
        }
    }
}
