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
import com.algorand.android.databinding.ItemTransactionStatusBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem
import com.algorand.android.utils.extensions.changeTextAppearance

class TransactionStatusViewHolder(
    private val binding: ItemTransactionStatusBinding
) : BaseViewHolder<TransactionDetailItem>(binding.root) {

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.StandardTransactionItem.StatusItem) return
        with(binding) {
            statusLabelTextView.setText(item.labelTextRes)
            statusTextView.apply {
                setText(item.transactionStatusTextRes)
                changeTextAppearance(item.transactionStatusTextStyleRes)
                setBackgroundResource(item.transactionStatusBackgroundRes)
                setTextColor(ContextCompat.getColor(context, item.transactionStatusTextColorRes))
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): TransactionStatusViewHolder {
            val binding = ItemTransactionStatusBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return TransactionStatusViewHolder(binding)
        }
    }
}
