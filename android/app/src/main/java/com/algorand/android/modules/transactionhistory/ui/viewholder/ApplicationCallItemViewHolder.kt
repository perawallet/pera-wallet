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

package com.algorand.android.modules.transactionhistory.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemApplicationCallTransactionBinding
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem

// TODO: extend this from base view holder
class ApplicationCallItemViewHolder(
    private val binding: ItemApplicationCallTransactionBinding,
    private val listener: ApplicationCallItemListener
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: BaseTransactionItem.TransactionItem.ApplicationCallItem) {
        with(item) {
            with(binding) {
                transactionTypeTextView.setText(item.nameRes)
                pendingTransactionProgressBar.isVisible = isPending
                applicationIdTextView.text = root.resources.getString(R.string.id_with_hash_tag, item.applicationId)
                innerTransactionCountTextView.text = if (innerTransactionCount > 0) {
                    root.resources.getQuantityString(
                        R.plurals.count_inner_txns,
                        innerTransactionCount,
                        innerTransactionCount
                    )
                } else {
                    null
                }
                root.setOnClickListener { listener.onApplicationCallItemClick(item) }
            }
        }
    }

    fun interface ApplicationCallItemListener {
        fun onApplicationCallItemClick(transaction: BaseTransactionItem.TransactionItem.ApplicationCallItem)
    }

    companion object {
        fun create(parent: ViewGroup, listener: ApplicationCallItemListener): ApplicationCallItemViewHolder {
            val binding =
                ItemApplicationCallTransactionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ApplicationCallItemViewHolder(binding, listener)
        }
    }
}
