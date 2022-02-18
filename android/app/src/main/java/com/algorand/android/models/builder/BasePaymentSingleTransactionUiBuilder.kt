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

import com.algorand.android.R
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.WalletConnectTransactionAmount
import com.algorand.android.models.WalletConnectTransactionShortDetail
import com.algorand.android.utils.ALGOS_SHORT_NAME
import javax.inject.Inject

class BasePaymentSingleTransactionUiBuilder @Inject constructor() :
    WalletConnectSingleTransactionUiBuilder<BasePaymentTransaction> {

    override fun buildToolbarTitleRes(txn: BasePaymentTransaction): Int {
        return R.string.transaction_request
    }

    override fun buildTransactionShortDetail(txn: BasePaymentTransaction): WalletConnectTransactionShortDetail {
        return with(txn) {
            WalletConnectTransactionShortDetail(
                accountIcon = createAccountIcon(),
                accountName = account?.name,
                accountBalance = assetInformation?.amount,
                assetShortName = assetInformation?.shortName,
                warningCount = warningCount,
                decimal = assetDecimal,
                fee = fee
            )
        }
    }

    override fun buildTransactionAmount(txn: BasePaymentTransaction): WalletConnectTransactionAmount {
        return with(txn) {
            WalletConnectTransactionAmount(
                transactionAmount = transactionAmount,
                assetDecimal = assetDecimal,
                assetShortName = ALGOS_SHORT_NAME,
                isNeedCurrencyValue = true,
                formattedSelectedCurrencyValue = assetInformation?.formattedSelectedCurrencyValue
            )
        }
    }
}
