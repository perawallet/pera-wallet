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
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseKeyRegTransaction
import com.algorand.android.models.BaseKeyRegTransaction.BaseOnlineKeyRegTransaction
import com.algorand.android.models.WalletConnectTransactionAmount
import com.algorand.android.models.WalletConnectTransactionShortDetail
import javax.inject.Inject

class BaseKeyRegSingleTransactionUiBuilder @Inject constructor() :
    WalletConnectSingleTransactionUiBuilder<BaseKeyRegTransaction> {

    override fun buildToolbarTitleRes(txn: BaseKeyRegTransaction): Int {
        return R.string.transaction_request
    }

    override fun buildTransactionShortDetail(txn: BaseKeyRegTransaction): WalletConnectTransactionShortDetail {
        return with(txn) {
            WalletConnectTransactionShortDetail(
                accountIconDrawablePreview = getFromAccountIconResource(),
                accountName = fromAccount?.name,
                warningCount = warningCount,
                decimal = assetDecimal,
                fee = fee
            )
        }
    }

    override fun buildTransactionAmount(txn: BaseKeyRegTransaction): WalletConnectTransactionAmount {
        val subtitleResId = if (txn is BaseOnlineKeyRegTransaction) R.string.online else R.string.offline
        return WalletConnectTransactionAmount(
            title = AnnotatedString(R.string.key_reg),
            subtitle = AnnotatedString(subtitleResId)
        )
    }
}
