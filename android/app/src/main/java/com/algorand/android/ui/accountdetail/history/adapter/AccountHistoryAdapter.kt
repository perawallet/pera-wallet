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
 *
 */

package com.algorand.android.ui.accountdetail.history.adapter

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseTransactionItem

class AccountHistoryAdapter(
    private val listener: Listener
) : PagingDataAdapter<BaseTransactionItem, RecyclerView.ViewHolder>(BaseDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is BaseTransactionItem.StringTitleItem -> R.layout.item_account_history_title
            is BaseTransactionItem.TransactionItem.Transaction -> R.layout.item_account_history_transaction
            is BaseTransactionItem.TransactionItem.Reward -> R.layout.item_account_history_transaction
            is BaseTransactionItem.TransactionItem.Fee -> R.layout.item_account_history_fee
            else -> throw Exception("$logTag: List Item is Unknown.")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_account_history_title -> createHistoryHeaderViewHolder(parent)
            R.layout.item_account_history_transaction -> createHistoryItemViewHolder(parent)
            R.layout.item_account_history_fee -> createHistoryFeeItemViewHolder(parent)
            else -> throw Exception("$logTag: List Item is Unknown.")
        }
    }

    private fun createHistoryHeaderViewHolder(parent: ViewGroup): AccountHistoryTitleViewHolder {
        return AccountHistoryTitleViewHolder.create(parent)
    }

    private fun createHistoryItemViewHolder(parent: ViewGroup): AccountHistoryTransactionItemViewHolder {
        return AccountHistoryTransactionItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    listener.onTransactionClick(getItem(bindingAdapterPosition) as BaseTransactionItem.TransactionItem)
                }
            }
        }
    }

    private fun createHistoryFeeItemViewHolder(parent: ViewGroup): AccountHistoryFeeViewHolder {
        return AccountHistoryFeeViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    listener.onTransactionClick(getItem(bindingAdapterPosition) as BaseTransactionItem.TransactionItem)
                }
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is AccountHistoryTitleViewHolder -> {
                holder.bind(getItem(position) as BaseTransactionItem.StringTitleItem)
            }
            is AccountHistoryTransactionItemViewHolder -> {
                holder.bind(getItem(position) as BaseTransactionItem.TransactionItem)
            }
            is AccountHistoryFeeViewHolder -> {
                holder.bind(getItem(position) as BaseTransactionItem.TransactionItem.Fee)
            }
        }
    }

    interface Listener {
        fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem)
    }

    companion object {
        private val logTag = AccountHistoryAdapter::class.java.simpleName
    }
}
