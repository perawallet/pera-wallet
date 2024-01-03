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

package com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemLedgerSelectionInstructionBinding
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.model.SearchType

class LedgerSelectionInstructionViewHolder(
    private val binding: ItemLedgerSelectionInstructionBinding
) : BaseViewHolder<AccountSelectionListItem>(binding.root) {

    override fun bind(item: AccountSelectionListItem) {
        if (item !is AccountSelectionListItem.InstructionItem) return
        binding.titleTextView.apply {
            text = resources.getQuantityString(R.plurals.account_found, item.accountCount, item.accountCount)
        }
        setDescriptionTextView(item.searchType)
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
