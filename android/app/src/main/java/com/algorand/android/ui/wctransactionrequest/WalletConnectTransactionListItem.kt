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

import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectTransaction

sealed class WalletConnectTransactionListItem {

    enum class ItemType {
        APP_PREVIEW,
        TITLE,
        MULTIPLE_TXN,
        SINGLE_TXN,
        GROUP_ID
    }

    abstract infix fun areItemsTheSame(other: WalletConnectTransactionListItem): Boolean
    abstract infix fun areContentsTheSame(other: WalletConnectTransactionListItem): Boolean

    abstract val getItemType: ItemType

    companion object {
        fun create(transaction: WalletConnectTransaction): List<WalletConnectTransactionListItem> {
            return with(transaction) {
                mutableListOf<WalletConnectTransactionListItem>().apply {
                    add(AppPreviewItem(session.peerMeta, message))
                    add(TitleItem(transactionList.size))
                    addAll(createTransactionItems(transactionList))
                }
            }
        }

        fun create(
            transactionList: List<BaseWalletConnectTransaction>,
            groupId: String?
        ): List<WalletConnectTransactionListItem> {
            return mutableListOf<WalletConnectTransactionListItem>().apply {
                if (!groupId.isNullOrBlank()) add(GroupIdItem(groupId))
                add(TitleItem(transactionList.size))
                addAll(transactionList.map { SingleTransactionItem(it) })
            }
        }

        private fun createTransactionItems(
            transactionList: List<List<BaseWalletConnectTransaction>>
        ): List<WalletConnectTransactionListItem> {
            return mutableListOf<WalletConnectTransactionListItem>().apply {
                transactionList.forEach { list ->
                    if (list.size > 1) {
                        add(MultipleTransactionItem(list))
                    } else if (list.isNotEmpty()) {
                        add(SingleTransactionItem(list.first()))
                    }
                }
            }
        }
    }

    data class AppPreviewItem(
        val peerMeta: WalletConnectPeerMeta,
        val message: String?
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.APP_PREVIEW

        override fun areItemsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is AppPreviewItem && peerMeta.url == other.peerMeta.url
        }

        override fun areContentsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is AppPreviewItem && peerMeta == other.peerMeta && message == message
        }
    }

    data class TitleItem(
        val transactionCount: Int
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.TITLE

        override fun areItemsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is TitleItem && transactionCount == other.transactionCount
        }

        override fun areContentsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is TitleItem && transactionCount == other.transactionCount
        }
    }

    data class MultipleTransactionItem(
        val transactionList: List<BaseWalletConnectTransaction>
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.MULTIPLE_TXN

        val groupId: String?
            get() = transactionList.firstOrNull()?.groupId

        override fun areItemsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is MultipleTransactionItem && transactionList.size == other.transactionList.size
        }

        override fun areContentsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is MultipleTransactionItem && transactionList == other.transactionList
        }
    }

    data class SingleTransactionItem(
        val transaction: BaseWalletConnectTransaction
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.SINGLE_TXN

        override fun areItemsTheSame(other: WalletConnectTransactionListItem): Boolean {
            if (other !is SingleTransactionItem) return false
            val transactionMsgPack = transaction.rawTransactionPayload.transactionMsgPack
            val otherTransactionMsgPack = other.transaction.rawTransactionPayload.transactionMsgPack
            return transactionMsgPack == otherTransactionMsgPack
        }

        override fun areContentsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is SingleTransactionItem && transaction == other.transaction
        }
    }

    data class GroupIdItem(
        val groupId: String
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.GROUP_ID

        override fun areItemsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is GroupIdItem && other.groupId == groupId
        }

        override fun areContentsTheSame(other: WalletConnectTransactionListItem): Boolean {
            return other is GroupIdItem && other.groupId == groupId
        }
    }
}
