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
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseTransactionListItem
import com.algorand.android.models.TransactionDiffCallback
import com.algorand.android.models.TransactionListItem

class PendingAdapter(
    private val onTransactionClick: (transaction: TransactionListItem) -> Unit,
    private val onNewPendingItemInserted: () -> Unit,
    diffCallback: TransactionDiffCallback
) : ListAdapter<BaseTransactionListItem, TransactionViewHolder>(diffCallback) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TransactionViewHolder {
        return TransactionViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    onTransactionClick(getItem(bindingAdapterPosition) as TransactionListItem)
                }
            }
        }
    }

    override fun onBindViewHolder(holder: TransactionViewHolder, position: Int) {
        holder.bind(getItem(position) as TransactionListItem)
    }

    override fun onCurrentListChanged(
        previousList: MutableList<BaseTransactionListItem>,
        currentList: MutableList<BaseTransactionListItem>
    ) {
        super.onCurrentListChanged(previousList, currentList)
        if (currentList.isNotEmpty()) {
            onNewPendingItemInserted()
        }
    }
}
