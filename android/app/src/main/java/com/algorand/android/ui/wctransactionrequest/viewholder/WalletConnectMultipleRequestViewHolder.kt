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

package com.algorand.android.ui.wctransactionrequest.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectMultipleRequestBinding
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.toShortenedAddress

class WalletConnectMultipleRequestViewHolder(
    private val binding: ItemWalletConnectMultipleRequestBinding,
    private val listener: OnShowDetailClickListener
) : BaseWalletConnectTransactionViewHolder(binding.root) {

    override fun bind(item: WalletConnectTransactionListItem) {
        if (item !is WalletConnectTransactionListItem.MultipleTransactionItem) return
        with(binding) {
            transactionCountTextView.text = getFormattedCountText(item.transactionList.size, item.groupId)
            transactionInfoImageView.isVisible = item.transactionList.any { it.warningCount != null }
            showTransactionDetailButton.setOnClickListener { listener.onShowDetailClick(item.transactionList) }
        }
    }

    private fun getFormattedCountText(transactionListSize: Int, groupId: String?): String {
        return binding.root.context.getXmlStyledString(
            R.string.transaction_count_group_id_formatted,
            listOf(
                "transaction_count" to transactionListSize.toString(),
                "group_id" to groupId.orEmpty().toShortenedAddress(GROUP_ID_SHORTENED_LETTER_COUNT)
            )
        ).toString()
    }

    companion object {

        private const val GROUP_ID_SHORTENED_LETTER_COUNT = 4

        fun create(parent: ViewGroup, listener: OnShowDetailClickListener): WalletConnectMultipleRequestViewHolder {
            val binding = ItemWalletConnectMultipleRequestBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectMultipleRequestViewHolder(binding, listener)
        }
    }

    fun interface OnShowDetailClickListener {
        fun onShowDetailClick(transactions: List<BaseWalletConnectTransaction>)
    }
}
