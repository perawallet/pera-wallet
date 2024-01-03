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

package com.algorand.android.ui.wctransactionrequest

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.ui.common.walletconnect.WalletConnectTransactionSummaryCardView
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.GROUP_ID
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.MULTIPLE_TXN
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.SINGLE_TXN
import com.algorand.android.ui.wctransactionrequest.viewholder.BaseWalletConnectTransactionViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectGroupIdViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectMultipleRequestViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectSingleRequestViewHolder

class WalletConnectTransactionAdapter(
    private val listener: Listener
) : ListAdapter<WalletConnectTransactionListItem, BaseWalletConnectTransactionViewHolder>(
    BaseDiffUtil<WalletConnectTransactionListItem>()
) {

    private val singleTransactionShowDetailClick = WalletConnectTransactionSummaryCardView.OnShowDetailClickListener {
        listener.onSingleTransactionClick(it)
    }

    private val multipleTransactionShowDetailClick = WalletConnectMultipleRequestViewHolder.OnShowDetailClickListener {
        listener.onMultipleTransactionClick(it)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).getItemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseWalletConnectTransactionViewHolder {
        return when (viewType) {
            MULTIPLE_TXN.ordinal -> createMultipleTransactionViewHolder(parent, multipleTransactionShowDetailClick)
            SINGLE_TXN.ordinal -> createSingleTransactionViewHolder(parent, singleTransactionShowDetailClick)
            GROUP_ID.ordinal -> WalletConnectGroupIdViewHolder.create(parent)
            else -> throw IllegalArgumentException("$logTag: Item View Type is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: BaseWalletConnectTransactionViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createMultipleTransactionViewHolder(
        parent: ViewGroup,
        multipleTransactionShowDetailClick: WalletConnectMultipleRequestViewHolder.OnShowDetailClickListener
    ): BaseWalletConnectTransactionViewHolder {
        return WalletConnectMultipleRequestViewHolder.create(parent, multipleTransactionShowDetailClick)
    }

    private fun createSingleTransactionViewHolder(
        parent: ViewGroup,
        onShowDetailClickListener: WalletConnectTransactionSummaryCardView.OnShowDetailClickListener
    ): BaseWalletConnectTransactionViewHolder {
        return WalletConnectSingleRequestViewHolder.create(parent, onShowDetailClickListener)
    }

    interface Listener {
        fun onMultipleTransactionClick(transactionList: List<BaseWalletConnectTransaction>) {}
        fun onSingleTransactionClick(transaction: BaseWalletConnectTransaction) {}
    }

    companion object {
        private val logTag = WalletConnectTransactionAdapter::class.java.simpleName
    }
}
