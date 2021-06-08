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

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AccountSelectionListItem

class LedgerAccountSelectionAdapter(
    private val searchType: SearchType,
    private val accountSelectionChanged: (Int) -> Unit,
    private val onAccountInfoClick: (AccountSelectionListItem) -> Unit
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private val accountSelectionList = mutableListOf<AccountSelectionListItem>()

    val isEmpty
        get() = accountSelectionList.isEmpty()

    val selectedCount
        get() = accountSelectionList.count { it.isSelected }

    override fun getItemViewType(position: Int): Int {
        return if (position == 0) {
            R.layout.item_ledger_selection_instruction
        } else {
            R.layout.item_account_selection
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_ledger_selection_instruction -> {
                LedgerSelectionInstructionViewHolder.create(parent, searchType)
            }
            R.layout.item_account_selection -> {
                LedgerAccountSelectionViewHolder.create(parent, searchType).apply {
                    itemView.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            onItemClicked(bindingAdapterPosition)
                        }
                    }
                    binding.infoButton.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            val accountSelectionListItem = getItem(bindingAdapterPosition)
                            onAccountInfoClick.invoke(accountSelectionListItem)
                        }
                    }
                }
            }
            else -> throw Exception("$logTag: Unknown ViewType $viewType")
        }
    }

    private fun onItemClicked(position: Int) {
        val clickedAccountSelectionListItem = getItem(position)
        val isItemSelectedBefore = clickedAccountSelectionListItem.isSelected
        if (searchType == SearchType.REKEY) {
            if (isItemSelectedBefore.not()) {
                accountSelectionList.forEachIndexed { index, accountSelectionListItem ->
                    if (accountSelectionListItem.isSelected) {
                        accountSelectionListItem.isSelected = false
                        notifyItemChanged(index + 1, SELECTED_PAYLOAD)
                    }
                }
            }
        }
        clickedAccountSelectionListItem.isSelected = !clickedAccountSelectionListItem.isSelected
        accountSelectionChanged.invoke(selectedCount)
        notifyItemChanged(position, SELECTED_PAYLOAD)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is LedgerSelectionInstructionViewHolder -> {
                holder.bind(accountSelectionList.size)
            }
            is LedgerAccountSelectionViewHolder -> {
                holder.bind(getItem(position))
            }
            else -> throw Exception("Unknown ViewHolder at $logTag")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int, payloads: MutableList<Any>) {
        if (payloads.isEmpty()) {
            super.onBindViewHolder(holder, position, payloads)
        } else {
            if (payloads.any { payload -> payload == SELECTED_PAYLOAD }) {
                (holder as? LedgerAccountSelectionViewHolder)?.bindSelection(getItem(position).isSelected)
            }
        }
    }

    private fun getItem(bindingAdapterPosition: Int): AccountSelectionListItem {
        return accountSelectionList[bindingAdapterPosition - 1]
    }

    fun setItems(accountSelectionList: List<AccountSelectionListItem>) {
        this.accountSelectionList.clear()
        this.accountSelectionList.addAll(accountSelectionList)
        notifyDataSetChanged()
    }

    fun getSelectedAccounts(): List<Account> {
        return accountSelectionList.filter { it.isSelected }.map { it.account }
    }

    fun getAllAuthAccounts(): List<Account> {
        return accountSelectionList.map { it.account }.filter { it.type == Account.Type.LEDGER }
    }

    // +1 added because of instruction.
    override fun getItemCount() = if (accountSelectionList.size != 0) accountSelectionList.size + 1 else 0

    companion object {
        private const val SELECTED_PAYLOAD = "selected_payload"
        private val logTag = LedgerAccountSelectionAdapter::class.java.simpleName
    }
}
