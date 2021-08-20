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

package com.algorand.android.ui.wctransactionrequest.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectMultipleRequestBinding
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem

class WalletConnectMultipleRequestViewHolder(
    private val binding: ItemWalletConnectMultipleRequestBinding
) : BaseWalletConnectTransactionViewHolder(binding.root) {

    override fun bind(item: WalletConnectTransactionListItem) {
        if (item !is WalletConnectTransactionListItem.MultipleTransactionItem) return
        binding.transactionCountTextView.text = getFormattedCountText(item.transactionList.size)
        binding.transactionInfoImageView.isVisible = item.transactionList.any { it.shouldShowWarningIndicator }
    }

    private fun getFormattedCountText(transactionListSize: Int): String {
        return binding.root.resources.getString(R.string.multiple_transactions_formatted, transactionListSize)
    }

    companion object {
        fun create(parent: ViewGroup): WalletConnectMultipleRequestViewHolder {
            val binding = ItemWalletConnectMultipleRequestBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectMultipleRequestViewHolder(binding)
        }
    }
}
