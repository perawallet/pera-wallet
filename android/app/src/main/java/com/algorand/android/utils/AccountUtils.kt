/*
 * Copyright 2019 Algorand, Inc.
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

package com.algorand.android.utils

import com.algorand.android.R
import com.algorand.android.models.Account

fun isRekeyedToAnotherAccount(authAddress: String?, accountAddress: String?): Boolean {
    return !authAddress.isNullOrBlank() && authAddress != accountAddress
}

fun getAccountImageResource(accountType: Account.Type?, isRekeyedToAnotherAccount: Boolean): Int {
    if (accountType != Account.Type.WATCH && isRekeyedToAnotherAccount) {
        return R.drawable.ic_rekeyed_ledger
    }
    return when (accountType) {
        Account.Type.STANDARD -> R.drawable.ic_standard_account
        Account.Type.LEDGER -> R.drawable.ic_ledger_vectorized
        Account.Type.WATCH -> R.drawable.ic_watch_account
        else -> R.drawable.ic_ledger_vectorized
    }
}
