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

package com.algorand.android.decider

import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.PendingTransaction
import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionItemType
import javax.inject.Inject

class TransactionNameDecider @Inject constructor() {

    fun provideTransactionName(transactionItemType: TransactionItemType): BaseTransactionItem.TransactionName {
        return when (transactionItemType) {
            TransactionItemType.ASSET_CREATION -> BaseTransactionItem.TransactionName.ASSET_ADDITION
            TransactionItemType.ASSET_REMOVAL -> BaseTransactionItem.TransactionName.ASSET_REMOVAL
            TransactionItemType.REKEY -> BaseTransactionItem.TransactionName.REKEY_ACCOUNT
            TransactionItemType.REWARD -> BaseTransactionItem.TransactionName.REWARD
            else -> BaseTransactionItem.TransactionName.UNDEFINED
        }
    }

    fun providePendingTransactionName(
        pendingTransaction: PendingTransaction,
        accountPublicKey: String
    ): BaseTransactionItem.TransactionName {
        with(pendingTransaction) {
            val receiverAddress = getReceiverAddress()
            val senderAddress = detail?.senderAddress.orEmpty()
            return when {
                senderAddress == accountPublicKey && receiverAddress == accountPublicKey -> {
                    // TODO: 17.01.2022  this case means the user's sending asset to self
                    BaseTransactionItem.TransactionName.RECEIVE
                }
                receiverAddress == accountPublicKey -> {
                    BaseTransactionItem.TransactionName.RECEIVE
                }
                else -> {
                    BaseTransactionItem.TransactionName.SEND
                }
            }
        }
    }

    fun provideTransferTransactionName(
        transaction: Transaction,
        accountPublicKey: String
    ): BaseTransactionItem.TransactionName {
        with(transaction) {
            val receiverAddress = getReceiverAddress()
            return when {
                senderAddress == accountPublicKey && receiverAddress == accountPublicKey -> {
                    // TODO: 17.01.2022  this case means the user's sending asset to self
                    BaseTransactionItem.TransactionName.RECEIVE
                }
                receiverAddress == accountPublicKey || getCloseToAddress() == accountPublicKey -> {
                    BaseTransactionItem.TransactionName.RECEIVE
                }
                else -> {
                    BaseTransactionItem.TransactionName.SEND
                }
            }
        }
    }
}
