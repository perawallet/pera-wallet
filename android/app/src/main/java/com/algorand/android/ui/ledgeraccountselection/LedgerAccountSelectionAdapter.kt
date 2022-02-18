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

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.BaseDiffUtil

class LedgerAccountSelectionAdapter(
    private val searchType: SearchType,
    private val listener: Listener,
) : ListAdapter<AccountSelectionListItem, RecyclerView.ViewHolder>(BaseDiffUtil<AccountSelectionListItem>()) {

    override fun submitList(list: List<AccountSelectionListItem>?) {
        if (searchType == SearchType.REKEY) {
            // Range is starting 1 because of instruction item
            // We are handling notify change state manually cause ListAdapter does not update multiple items at the
            // same time if the list size is the same
            list?.let { notifyItemRangeChanged(1, it.count()) }
        }
        super.submitList(list)
    }

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is AccountSelectionListItem.AccountItem -> R.layout.item_account_selection
            is AccountSelectionListItem.InstructionItem -> R.layout.item_ledger_selection_instruction
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_ledger_selection_instruction -> createInstructionItemViewHolder(parent)
            R.layout.item_account_selection -> createAccountItemViewHolder(parent)
            else -> throw Exception("$logTag: Unknown ViewType $viewType")
        }
    }

    private fun createInstructionItemViewHolder(parent: ViewGroup): LedgerSelectionInstructionViewHolder {
        return LedgerSelectionInstructionViewHolder.create(parent)
    }

    private fun createAccountItemViewHolder(parent: ViewGroup): LedgerAccountSelectionViewHolder {
        return LedgerAccountSelectionViewHolder.create(parent, searchType).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    (getItem(bindingAdapterPosition) as? AccountSelectionListItem.AccountItem)?.let {
                        notifyItemChanged(bindingAdapterPosition)
                        listener.onAccountClick(it)
                    }
                }
            }
            binding.infoButton.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    (getItem(bindingAdapterPosition) as? AccountSelectionListItem.AccountItem)?.let {
                        listener.onAccountInfoClick(it)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is LedgerSelectionInstructionViewHolder -> {
                holder.bind(getItem(position) as AccountSelectionListItem.InstructionItem, searchType)
            }
            is LedgerAccountSelectionViewHolder -> {
                holder.bind(getItem(position) as AccountSelectionListItem.AccountItem)
            }
            else -> throw Exception("Unknown ViewHolder at $logTag")
        }
    }

    interface Listener {
        fun onAccountClick(accountItem: AccountSelectionListItem.AccountItem)
        fun onAccountInfoClick(accountItem: AccountSelectionListItem.AccountItem)
    }

    companion object {
        private val logTag = LedgerAccountSelectionAdapter::class.java.simpleName
    }
}
