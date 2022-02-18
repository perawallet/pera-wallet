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

package com.algorand.android.utils.analytics

import androidx.core.os.bundleOf
import com.algorand.android.models.Account
import com.google.firebase.analytics.FirebaseAnalytics
import java.math.BigInteger

private const val TRANSACTION_EVENT_KEY = "transaction" // event type

private const val TRANSACTION_ACCOUNT_TYPE_KEY = "account_type" // param
private const val TRANSACTION_STANDARD_ACCOUNT_KEY = "standard" // value
private const val TRANSACTION_LEDGER_ACCOUNT_KEY = "ledger" // value

private const val TRANSACTION_AMOUNT = "amount" // param
private const val TRANSACTION_IS_MAX = "is_max" // param
private const val TRANSACTION_ASSET_ID = "asset_id" // param
private const val TRANSACTION_ID = "tx_id" // param

fun FirebaseAnalytics.logTransactionEvent(
    amount: BigInteger,
    assetId: Long,
    accountType: Account.Type,
    isMax: Boolean,
    transactionId: String?
) {
    val accountTypeValue = when (accountType) {
        Account.Type.STANDARD -> TRANSACTION_STANDARD_ACCOUNT_KEY
        Account.Type.LEDGER -> TRANSACTION_LEDGER_ACCOUNT_KEY
        else -> "other"
    }

    val bundle = bundleOf(
        (TRANSACTION_AMOUNT to amount),
        (TRANSACTION_ACCOUNT_TYPE_KEY to accountTypeValue),
        (TRANSACTION_IS_MAX to isMax.toString()),
        (TRANSACTION_ASSET_ID to getAssetIdAsEventParam(assetId)),
        (TRANSACTION_ID to transactionId.orEmpty())
    )

    logEvent(TRANSACTION_EVENT_KEY, bundle)
}
