/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models.builder

import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.decider.WalletConnectTransactionSummaryUiDecider
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem
import javax.inject.Inject

class WalletConnectTransactionListBuilder @Inject constructor(
    private val transactionSummaryUiDecider: WalletConnectTransactionSummaryUiDecider
) {

    fun create(
        transactionList: List<BaseWalletConnectTransaction>,
        groupId: String?
    ): List<WalletConnectTransactionListItem> {
        return mutableListOf<WalletConnectTransactionListItem>().apply {
            if (!groupId.isNullOrBlank()) add(WalletConnectTransactionListItem.GroupIdItem(groupId))
            addAll(
                transactionList.map {
                    WalletConnectTransactionListItem.SingleTransactionItem(
                        it,
                        transactionSummaryUiDecider.buildTransactionSummary(it)
                    )
                }
            )
        }
    }

    fun createTransactionItems(
        transactionList: List<List<BaseWalletConnectTransaction>>
    ): List<WalletConnectTransactionListItem> {
        return mutableListOf<WalletConnectTransactionListItem>().apply {
            transactionList.forEach { list ->
                if (list.size > 1) {
                    add(WalletConnectTransactionListItem.MultipleTransactionItem(list))
                } else if (list.isNotEmpty()) {
                    val transaction = list.first()
                    val singleTransactionItem = WalletConnectTransactionListItem.SingleTransactionItem(
                        transaction,
                        transactionSummaryUiDecider.buildTransactionSummary(transaction)
                    )
                    add(singleTransactionItem)
                }
            }
        }
    }
}
