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
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder

class LedgerAccountSelectionAdapter(
    private val listener: Listener,
) : ListAdapter<AccountSelectionListItem, BaseViewHolder<AccountSelectionListItem>>(BaseDiffUtil()) {

    private val ledgerAccountSelectionViewHolderListener = object : LedgerAccountSelectionViewHolder.Listener {
        override fun onAccountItemClick(accountItem: AccountSelectionListItem.AccountItem) {
            listener.onAccountClick(accountItem)
        }

        override fun onAccountInfoClick(accountItem: AccountSelectionListItem.AccountItem) {
            listener.onAccountInfoClick(accountItem)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<AccountSelectionListItem> {
        return when (viewType) {
            AccountSelectionListItem.ItemType.INSTRUCTION_ITEM.ordinal -> createInstructionItemViewHolder(parent)
            AccountSelectionListItem.ItemType.ACCOUNT_ITEM.ordinal -> createAccountItemViewHolder(parent)
            else -> throw Exception("$logTag: Unknown ViewType $viewType")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<AccountSelectionListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createInstructionItemViewHolder(parent: ViewGroup): LedgerSelectionInstructionViewHolder {
        return LedgerSelectionInstructionViewHolder.create(parent)
    }

    private fun createAccountItemViewHolder(parent: ViewGroup): LedgerAccountSelectionViewHolder {
        return LedgerAccountSelectionViewHolder.create(parent, ledgerAccountSelectionViewHolderListener)
    }

    interface Listener {
        fun onAccountClick(accountItem: AccountSelectionListItem.AccountItem)
        fun onAccountInfoClick(accountItem: AccountSelectionListItem.AccountItem)
    }

    companion object {
        private val logTag = LedgerAccountSelectionAdapter::class.java.simpleName
    }
}
