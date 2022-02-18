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
import com.algorand.android.models.WalletConnectTransactionSummary
import com.algorand.android.models.builder.BaseAppCallTransactionSummaryUiBuilder
import com.algorand.android.models.builder.BaseAssetConfigurationTransactionSummaryUiBuilder
import com.algorand.android.models.builder.BaseAssetTransferTransactionSummaryUiBuilder
import com.algorand.android.models.builder.BasePaymentTransactionSummaryUiBuilder
import com.algorand.android.models.builder.WalletConnectTransactionSummaryUIBuilder
import javax.inject.Inject

class WalletConnectTransactionSummaryUiDecider @Inject constructor(
    private val basePaymentTransactionSummaryUiBuilder: BasePaymentTransactionSummaryUiBuilder,
    private val baseAssetTransferTransactionSummaryUiBuilder: BaseAssetTransferTransactionSummaryUiBuilder,
    private val baseAssetConfigurationTransactionSummaryUiBuilder: BaseAssetConfigurationTransactionSummaryUiBuilder,
    private val baseAppCallTransactionSummaryUiBuilder: BaseAppCallTransactionSummaryUiBuilder
) {

    fun buildTransactionSummary(txn: BaseWalletConnectTransaction): WalletConnectTransactionSummary {
        return getTxnTypeUiBuilder(txn).buildTransactionSummary(txn)
    }

    private fun getTxnTypeUiBuilder(
        txn: BaseWalletConnectTransaction
    ): WalletConnectTransactionSummaryUIBuilder<BaseWalletConnectTransaction> {
        return when (txn) {
            is BasePaymentTransaction -> basePaymentTransactionSummaryUiBuilder
            is BaseAssetTransferTransaction -> baseAssetTransferTransactionSummaryUiBuilder
            is BaseAssetConfigurationTransaction -> baseAssetConfigurationTransactionSummaryUiBuilder
            is BaseAppCallTransaction -> baseAppCallTransactionSummaryUiBuilder
            else -> throw Exception("Unknown wallet connect transaction type.")
        } as WalletConnectTransactionSummaryUIBuilder<BaseWalletConnectTransaction>
    }
}
