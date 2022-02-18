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

package com.algorand.android.models.decider

import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.TransactionRequestAmountInfo
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.models.TransactionRequestSenderInfo
import com.algorand.android.models.TransactionRequestTransactionInfo
import com.algorand.android.models.builder.BaseAppCallTransactionDetailUiBuilder
import com.algorand.android.models.builder.BaseAssetConfigurationTransactionDetailUiBuilder
import com.algorand.android.models.builder.BaseAssetTransferTransactionDetailUiBuilder
import com.algorand.android.models.builder.BasePaymentTransactionDetailUiBuilder
import com.algorand.android.models.builder.WalletConnectTransactionDetailBuilder
import javax.inject.Inject

class WalletConnectTransactionDetailUiDecider @Inject constructor(
    private val basePaymentTransactionDetailUiBuilder: BasePaymentTransactionDetailUiBuilder,
    private val baseAssetTransferTransactionDetailUiBuilder: BaseAssetTransferTransactionDetailUiBuilder,
    private val baseAssetConfigurationTransactionDetailUiBuilder: BaseAssetConfigurationTransactionDetailUiBuilder,
    private val baseAppCallTransactionDetailUiBuilder: BaseAppCallTransactionDetailUiBuilder
) {

    fun buildTransactionRequestTransactionInfo(txn: BaseWalletConnectTransaction): TransactionRequestTransactionInfo? {
        return getTxnTypeUiBuilder(txn).buildTransactionRequestTransactionInfo(txn)
    }

    fun buildTransactionRequestSenderInfo(txn: BaseWalletConnectTransaction): TransactionRequestSenderInfo? {
        return getTxnTypeUiBuilder(txn).buildTransactionRequestSenderInfo(txn)
    }

    fun buildTransactionRequestNoteInfo(txn: BaseWalletConnectTransaction): TransactionRequestNoteInfo? {
        return getTxnTypeUiBuilder(txn).buildTransactionRequestNoteInfo(txn)
    }

    fun buildTransactionRequestExtrasInfo(txn: BaseWalletConnectTransaction): TransactionRequestExtrasInfo {
        return getTxnTypeUiBuilder(txn).buildTransactionRequestExtrasInfo(txn)
    }

    fun buildTransactionRequestAmountInfo(txn: BaseWalletConnectTransaction): TransactionRequestAmountInfo {
        return getTxnTypeUiBuilder(txn).buildTransactionRequestAmountInfo(txn)
    }

    private fun getTxnTypeUiBuilder(
        txn: BaseWalletConnectTransaction
    ): WalletConnectTransactionDetailBuilder<BaseWalletConnectTransaction> {
        return when (txn) {
            is BasePaymentTransaction -> basePaymentTransactionDetailUiBuilder
            is BaseAssetTransferTransaction -> baseAssetTransferTransactionDetailUiBuilder
            is BaseAssetConfigurationTransaction -> baseAssetConfigurationTransactionDetailUiBuilder
            is BaseAppCallTransaction -> baseAppCallTransactionDetailUiBuilder
            else -> throw Exception("Unknown wallet connect transaction type.")
        } as WalletConnectTransactionDetailBuilder<BaseWalletConnectTransaction>
    }
}
