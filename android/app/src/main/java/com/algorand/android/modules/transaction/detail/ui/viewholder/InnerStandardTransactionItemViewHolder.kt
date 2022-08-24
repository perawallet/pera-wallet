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
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.ItemInnerTransactionBinding
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem

class InnerStandardTransactionItemViewHolder(
    private val binding: ItemInnerTransactionBinding,
    private val listener: InnerTransactionItemListener
) : BaseInnerTransactionItemViewHolder(binding.root) {

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.InnerTransactionItem.StandardInnerTransactionItem) return
        with(binding) {
            transactionAddressTextView.text = item.accountAddress
            transactionAmountTextView.apply {
                val transactionSign = item.transactionSign.signTextRes?.run { context.getString(this) }.orEmpty()
                text = context.getString(
                    R.string.pair_value_format_packed,
                    transactionSign,
                    item.formattedTransactionAmount
                )
                setTextColor(ContextCompat.getColor(context, item.transactionSign.color))
            }
            root.setOnClickListener { listener.onStandardTransactionClick(item) }
        }
    }

    companion object : InnerTransactionItemViewHolderCreator {
        override fun create(
            parent: ViewGroup,
            listener: InnerTransactionItemListener
        ): InnerStandardTransactionItemViewHolder {
            val binding = ItemInnerTransactionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return InnerStandardTransactionItemViewHolder(binding, listener)
        }
    }
}
