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

import android.os.Parcelable
import androidx.annotation.Keep
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectTransactionSummary
import kotlinx.parcelize.Parcelize

@Keep
sealed class WalletConnectTransactionListItem : Parcelable, RecyclerListItem {

    enum class ItemType {
        APP_PREVIEW,
        TITLE,
        MULTIPLE_TXN,
        SINGLE_TXN,
        GROUP_ID
    }

    abstract val getItemType: ItemType

    @Parcelize
    data class AppPreviewItem(
        val peerMeta: WalletConnectPeerMeta,
        val message: String?
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.APP_PREVIEW

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AppPreviewItem && peerMeta.url == other.peerMeta.url
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AppPreviewItem && peerMeta == other.peerMeta && message == message
        }
    }

    @Parcelize
    data class TitleItem(
        val transactionCount: Int
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.TITLE

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && transactionCount == other.transactionCount
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && transactionCount == other.transactionCount
        }
    }

    @Parcelize
    data class MultipleTransactionItem(
        val transactionList: List<BaseWalletConnectTransaction>
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.MULTIPLE_TXN

        val groupId: String?
            get() = transactionList.firstOrNull()?.groupId

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is MultipleTransactionItem && transactionList.size == other.transactionList.size
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is MultipleTransactionItem && transactionList == other.transactionList
        }
    }

    @Parcelize
    @Keep
    data class SingleTransactionItem(
        val transaction: BaseWalletConnectTransaction,
        val transactionSummary: WalletConnectTransactionSummary
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.SINGLE_TXN

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            if (other !is SingleTransactionItem) return false
            val transactionMsgPack = transaction.rawTransactionPayload.transactionMsgPack
            val otherTransactionMsgPack = other.transaction.rawTransactionPayload.transactionMsgPack
            return transactionMsgPack == otherTransactionMsgPack
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SingleTransactionItem && transaction == other.transaction
        }
    }

    @Parcelize
    data class GroupIdItem(
        val groupId: String
    ) : WalletConnectTransactionListItem() {

        override val getItemType: ItemType
            get() = ItemType.GROUP_ID

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is GroupIdItem && other.groupId == groupId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is GroupIdItem && other.groupId == groupId
        }
    }
}
