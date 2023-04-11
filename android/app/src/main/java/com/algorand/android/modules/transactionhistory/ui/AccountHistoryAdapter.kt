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

package com.algorand.android.modules.transactionhistory.ui

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.modules.transactionhistory.ui.viewholder.AccountHistoryTitleViewHolder
import com.algorand.android.modules.transactionhistory.ui.viewholder.AccountHistoryTransactionItemViewHolder
import com.algorand.android.modules.transactionhistory.ui.viewholder.ApplicationCallItemViewHolder

class AccountHistoryAdapter(
    private val listener: Listener
) : PagingDataAdapter<BaseTransactionItem, RecyclerView.ViewHolder>(BaseDiffUtil()) {

    private val applicationCallItemListener = ApplicationCallItemViewHolder.ApplicationCallItemListener {
        listener.onApplicationCallTransactionClick(it)
    }

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is BaseTransactionItem.StringTitleItem -> R.layout.item_account_history_title
            is BaseTransactionItem.TransactionItem.ApplicationCallItem -> R.layout.item_application_call_transaction
            is BaseTransactionItem.TransactionItem -> R.layout.item_account_history_transaction
            else -> throw Exception("$logTag: List Item is Unknown.")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_account_history_title -> createHistoryHeaderViewHolder(parent)
            R.layout.item_account_history_transaction -> createHistoryItemViewHolder(parent)
            R.layout.item_application_call_transaction -> createApplicationCallItemViewHolder(parent)
            else -> throw Exception("$logTag: List Item is Unknown.")
        }
    }

    fun getTitleForPosition(position: Int): String? {
        if (position in 0 until itemCount) {
            var currentPosition = position
            while (currentPosition >= 0) {
                val currentItem = getItem(currentPosition)
                if (currentItem is BaseTransactionItem.StringTitleItem) return currentItem.title
                currentPosition--
            }
        }
        return null
    }

    private fun createApplicationCallItemViewHolder(parent: ViewGroup): RecyclerView.ViewHolder {
        return ApplicationCallItemViewHolder.create(parent, applicationCallItemListener)
    }

    private fun createHistoryHeaderViewHolder(parent: ViewGroup): AccountHistoryTitleViewHolder {
        return AccountHistoryTitleViewHolder.create(parent)
    }

    private fun createHistoryItemViewHolder(parent: ViewGroup): AccountHistoryTransactionItemViewHolder {
        return AccountHistoryTransactionItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    listener.onStandardTransactionClick(
                        getItem(bindingAdapterPosition) as BaseTransactionItem.TransactionItem
                    )
                }
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is AccountHistoryTitleViewHolder -> {
                holder.bind(getItem(position) as BaseTransactionItem.StringTitleItem)
            }
            is ApplicationCallItemViewHolder -> {
                holder.bind(getItem(position) as BaseTransactionItem.TransactionItem.ApplicationCallItem)
            }
            is AccountHistoryTransactionItemViewHolder -> {
                holder.bind(getItem(position) as BaseTransactionItem.TransactionItem)
            }
        }
    }

    interface Listener {
        fun onStandardTransactionClick(transaction: BaseTransactionItem.TransactionItem)
        fun onApplicationCallTransactionClick(transaction: BaseTransactionItem.TransactionItem.ApplicationCallItem)
    }

    companion object {
        private val logTag = AccountHistoryAdapter::class.java.simpleName
    }
}
