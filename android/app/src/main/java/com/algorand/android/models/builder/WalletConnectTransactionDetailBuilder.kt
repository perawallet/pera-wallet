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
import com.algorand.android.models.TransactionRequestAmountInfo
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.models.TransactionRequestSenderInfo
import com.algorand.android.models.TransactionRequestTransactionInfo

interface WalletConnectTransactionDetailBuilder<T : BaseWalletConnectTransaction> : WalletConnectUIBuilder {

    fun buildTransactionRequestTransactionInfo(txn: T): TransactionRequestTransactionInfo? {
        return null
    }

    fun buildTransactionRequestSenderInfo(txn: T): TransactionRequestSenderInfo? {
        return null
    }

    fun buildTransactionRequestNoteInfo(txn: T): TransactionRequestNoteInfo?

    fun buildTransactionRequestExtrasInfo(txn: T): TransactionRequestExtrasInfo

    fun buildTransactionRequestAmountInfo(txn: T): TransactionRequestAmountInfo
}
