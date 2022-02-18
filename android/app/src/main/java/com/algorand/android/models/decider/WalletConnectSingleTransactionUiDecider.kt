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
import com.algorand.android.models.WalletConnectTransactionAmount
import com.algorand.android.models.WalletConnectTransactionShortDetail
import com.algorand.android.models.builder.BaseAppCallSingleTransactionUiBuilder
import com.algorand.android.models.builder.BaseAssetConfigurationSingleTransactionUiBuilder
import com.algorand.android.models.builder.BaseAssetTransferSingleTransactionUiBuilder
import com.algorand.android.models.builder.BasePaymentSingleTransactionUiBuilder
import com.algorand.android.models.builder.WalletConnectSingleTransactionUiBuilder
import javax.inject.Inject

class WalletConnectSingleTransactionUiDecider @Inject constructor(
    private val basePaymentSingleTransactionUiBuilder: BasePaymentSingleTransactionUiBuilder,
    private val baseAssetTransferSingleTransactionUiBuilder: BaseAssetTransferSingleTransactionUiBuilder,
    private val baseAssetConfigurationSingleTransactionUiBuilder: BaseAssetConfigurationSingleTransactionUiBuilder,
    private val baseAppCallSingleTransactionUiBuilder: BaseAppCallSingleTransactionUiBuilder
) {

    fun buildToolbarTitleRes(txn: BaseWalletConnectTransaction): Int {
        return getTxnTypeUiBuilder(txn).buildToolbarTitleRes(txn)
    }

    fun buildTransactionAmount(txn: BaseWalletConnectTransaction): WalletConnectTransactionAmount {
        return getTxnTypeUiBuilder(txn).buildTransactionAmount(txn)
    }

    fun buildTransactionShortDetail(txn: BaseWalletConnectTransaction): WalletConnectTransactionShortDetail {
        return getTxnTypeUiBuilder(txn).buildTransactionShortDetail(txn)
    }

    private fun getTxnTypeUiBuilder(
        txn: BaseWalletConnectTransaction
    ): WalletConnectSingleTransactionUiBuilder<BaseWalletConnectTransaction> {
        return when (txn) {
            is BasePaymentTransaction -> basePaymentSingleTransactionUiBuilder
            is BaseAssetTransferTransaction -> baseAssetTransferSingleTransactionUiBuilder
            is BaseAssetConfigurationTransaction -> baseAssetConfigurationSingleTransactionUiBuilder
            is BaseAppCallTransaction -> baseAppCallSingleTransactionUiBuilder
            else -> throw Exception("Unknown wallet connect transaction type.")
        } as WalletConnectSingleTransactionUiBuilder<BaseWalletConnectTransaction>
    }
}
