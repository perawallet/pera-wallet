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

import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.WalletConnectTransactionAmount
import com.algorand.android.models.WalletConnectTransactionShortDetail
import javax.inject.Inject

class BaseAppCallSingleTransactionUiBuilder @Inject constructor() :
    WalletConnectSingleTransactionUiBuilder<BaseAppCallTransaction> {

    override fun buildToolbarTitleRes(txn: BaseAppCallTransaction): Int {
        return txn.appOnComplete.titleResId
    }

    override fun buildTransactionShortDetail(txn: BaseAppCallTransaction): WalletConnectTransactionShortDetail {
        return with(txn) {
            WalletConnectTransactionShortDetail(
                accountIcon = createAccountIcon(),
                accountName = account?.name,
                warningCount = warningCount,
                decimal = assetDecimal,
                fee = fee
            )
        }
    }

    override fun buildTransactionAmount(txn: BaseAppCallTransaction): WalletConnectTransactionAmount {
        return when (txn) {
            is BaseAppCallTransaction.AppCallCreationTransaction -> buildAppCreationTransactionAmount(txn)
            else -> WalletConnectTransactionAmount(applicationId = txn.appId)
        }
    }

    private fun buildAppCreationTransactionAmount(
        txn: BaseAppCallTransaction.AppCallCreationTransaction
    ): WalletConnectTransactionAmount {
        return WalletConnectTransactionAmount(appOnComplete = txn.appOnComplete)
    }
}
