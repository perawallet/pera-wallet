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
import com.algorand.android.databinding.ItemLedgerSelectionInstructionBinding
import com.algorand.android.models.AccountSelectionListItem

class LedgerSelectionInstructionViewHolder(
    private val binding: ItemLedgerSelectionInstructionBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: AccountSelectionListItem.InstructionItem, searchType: SearchType) {
        binding.titleTextView.apply {
            text = resources.getQuantityString(R.plurals.account_found, item.accountCount, item.accountCount)
        }
        setDescriptionTextView(searchType)
    }

    private fun setDescriptionTextView(searchType: SearchType) {
        binding.descriptionTextView.setText(
            if (searchType == SearchType.REGISTER) {
                R.string.this_ledger_device
            } else {
                R.string.choose_the_account
            }
        )
    }

    companion object {
        fun create(parent: ViewGroup): LedgerSelectionInstructionViewHolder {
            val binding = ItemLedgerSelectionInstructionBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return LedgerSelectionInstructionViewHolder(binding)
        }
    }
}
