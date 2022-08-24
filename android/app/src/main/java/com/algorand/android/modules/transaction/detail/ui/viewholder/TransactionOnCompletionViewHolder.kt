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
import com.algorand.android.databinding.ItemTransactionOnCompletionBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem

class TransactionOnCompletionViewHolder(
    private val binding: ItemTransactionOnCompletionBinding
) : BaseViewHolder<TransactionDetailItem>(binding.root) {

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.ApplicationCallItem.OnCompletionItem) return
        with(binding) {
            onCompletionLabelTextView.setText(item.labelTextRes)
            if (item.onCompletionTextRes != null) {
                onCompletionTextView.setText(item.onCompletionTextRes)
            } else {
                onCompletionTextView.text = ""
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): TransactionOnCompletionViewHolder {
            val binding = ItemTransactionOnCompletionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return TransactionOnCompletionViewHolder(binding)
        }
    }
}
