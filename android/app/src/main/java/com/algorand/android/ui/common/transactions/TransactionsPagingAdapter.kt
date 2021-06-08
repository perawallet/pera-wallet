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

package com.algorand.android.ui.common.transactions

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseTransactionListItem
import com.algorand.android.models.ClaimedRewardListItem
import com.algorand.android.models.TransactionDiffCallback
import com.algorand.android.models.TransactionListItem

class TransactionsPagingAdapter(
    private val onTransactionClick: (TransactionListItem) -> Unit,
    diffCallback: TransactionDiffCallback
) : PagingDataAdapter<BaseTransactionListItem, RecyclerView.ViewHolder>(diffCallback) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position)!!.viewType
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is TransactionViewHolder -> {
                holder.bind(getItem(position) as TransactionListItem)
            }
            is ClaimedRewardViewHolder -> {
                holder.bind(getItem(position) as ClaimedRewardListItem)
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            BaseTransactionListItem.Type.TRANSACTION.ordinal -> TransactionViewHolder.create(parent).apply {
                itemView.setOnClickListener {
                    if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                        (getItem(bindingAdapterPosition) as? TransactionListItem)?.let { transactionListItem ->
                            onTransactionClick(transactionListItem)
                        }
                    }
                }
            }
            BaseTransactionListItem.Type.REWARD.ordinal -> ClaimedRewardViewHolder.create(parent)
            else -> throw Exception("")
        }
    }
}
