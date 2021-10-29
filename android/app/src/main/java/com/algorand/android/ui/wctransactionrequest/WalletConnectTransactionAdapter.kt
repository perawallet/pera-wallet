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

package com.algorand.android.ui.wctransactionrequest

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.ui.common.walletconnect.WalletConnectAppPreviewCardView
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.APP_PREVIEW
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.GROUP_ID
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.MULTIPLE_TXN
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.SINGLE_TXN
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.ItemType.TITLE
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.MultipleTransactionItem
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem.SingleTransactionItem
import com.algorand.android.ui.wctransactionrequest.viewholder.BaseWalletConnectTransactionViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectAppPreviewViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectGroupIdViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectMultipleRequestViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectRequestTitleViewHolder
import com.algorand.android.ui.wctransactionrequest.viewholder.WalletConnectSingleRequestViewHolder

class WalletConnectTransactionAdapter(
    private val listener: Listener
) : ListAdapter<WalletConnectTransactionListItem, BaseWalletConnectTransactionViewHolder>(
    WalletConnectTransactionListDiffUtil()
) {

    private val onShowMoreClickListener = WalletConnectAppPreviewCardView.OnShowMoreClickListener { peerMeta, message ->
        listener.onShowMoreMessageClick(peerMeta, message)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).getItemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseWalletConnectTransactionViewHolder {
        return when (viewType) {
            APP_PREVIEW.ordinal -> WalletConnectAppPreviewViewHolder.create(parent, onShowMoreClickListener)
            TITLE.ordinal -> WalletConnectRequestTitleViewHolder.create(parent)
            MULTIPLE_TXN.ordinal -> createMultipleTransactionViewHolder(parent)
            SINGLE_TXN.ordinal -> createSingleTransactionViewHolder(parent)
            GROUP_ID.ordinal -> WalletConnectGroupIdViewHolder.create(parent)
            else -> throw IllegalArgumentException("$logTag: Item View Type is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: BaseWalletConnectTransactionViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createMultipleTransactionViewHolder(parent: ViewGroup): BaseWalletConnectTransactionViewHolder {
        return WalletConnectMultipleRequestViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    val transactionList = (getItem(bindingAdapterPosition) as MultipleTransactionItem).transactionList
                    listener.onMultipleTransactionClick(transactionList)
                }
            }
        }
    }

    private fun createSingleTransactionViewHolder(parent: ViewGroup): BaseWalletConnectTransactionViewHolder {
        return WalletConnectSingleRequestViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    val transaction = (getItem(bindingAdapterPosition) as SingleTransactionItem).transaction
                    listener.onSingleTransactionClick(transaction)
                }
            }
        }
    }

    interface Listener {
        fun onMultipleTransactionClick(transactionList: List<BaseWalletConnectTransaction>) {}
        fun onSingleTransactionClick(transaction: BaseWalletConnectTransaction)
        fun onShowMoreMessageClick(peerMeta: WalletConnectPeerMeta, message: String) {}
    }

    companion object {
        private val logTag = WalletConnectTransactionAdapter::class.java.simpleName
    }
}
