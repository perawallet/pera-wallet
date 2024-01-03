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

package com.algorand.android.modules.transaction.detail.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemTransactionIdBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem

class TransactionIdViewHolder(
    private val binding: ItemTransactionIdBinding,
    private val listener: Listener
) : BaseViewHolder<TransactionDetailItem>(binding.root) {

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.StandardTransactionItem.TransactionIdItem) return
        with(binding) {
            transactionIdLabelTextView.setText(item.labelTextRes)
            transactionIdView.text = item.transactionId
            root.setOnLongClickListener { listener.onTransactionIdLongClick(item.transactionId); true }
        }
    }

    interface Listener {
        fun onTransactionIdLongClick(transactionId: String)
    }

    companion object {
        fun create(parent: ViewGroup, transactionIdListener: Listener): TransactionIdViewHolder {
            val binding = ItemTransactionIdBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return TransactionIdViewHolder(binding, transactionIdListener)
        }
    }
}
