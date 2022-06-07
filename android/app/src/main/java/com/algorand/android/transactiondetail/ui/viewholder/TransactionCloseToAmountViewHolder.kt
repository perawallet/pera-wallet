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

package com.algorand.android.transactiondetail.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.ItemTransactionCloseAmountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem

class TransactionCloseToAmountViewHolder(
    private val binding: ItemTransactionCloseAmountBinding
) : BaseViewHolder<TransactionDetailItem>(binding.root) {

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.AmountItem.CloseAmountItem) return
        with(binding) {
            closeAmountLabelTextView.setText(item.labelTextRes)
            closeAmountView.apply {
                setTextColor(ContextCompat.getColor(context, item.transactionSign.color))
                val transactionSign = item.transactionSign.signTextRes?.run { context.getString(this) }
                text = context.getString(
                    R.string.pair_value_format_packed,
                    transactionSign,
                    item.formattedTransactionAmount
                )
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): TransactionCloseToAmountViewHolder {
            val binding = ItemTransactionCloseAmountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return TransactionCloseToAmountViewHolder(binding)
        }
    }
}
