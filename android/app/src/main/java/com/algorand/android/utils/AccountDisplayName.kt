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

package com.algorand.android.utils

import android.content.res.Resources
import android.os.Parcelable
import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.Account.Type.LEDGER
import com.algorand.android.models.Account.Type.REKEYED
import com.algorand.android.models.Account.Type.REKEYED_AUTH
import com.algorand.android.models.Account.Type.WATCH
import kotlinx.parcelize.Parcelize

/**
 *
 * Account Naming Rule;
 *
 * If account is renamed;
 *  - If account matches with NFDomain;
 *      + Primary display name: Given custom name (Spending Account)
 *      + Secondary display name: NFDomain service name (pera.algo)
 *  - If account doesn't match with NFDomain;
 *      + Primary display name: Given custom name (Spending Account)
 *      + Secondary display name: Shortened account address: (XCSASD...ZSFFSW)
 * If account didn't rename;
 *  - If account matches with NFDomain;
 *      + Primary display name: NFDomain service name (pera.algo)
 *      + Secondary display name: Shortened account address: (XCSASD...ZSFFSW)
 *  - If account doesn't match with NFDomain;
 *      + Primary display name: Shortened account address: (XCSASD...ZSFFSW)
 *      + Secondary display name:
 *          - If Ledger account: Ledger Account
 *          - If Rekeyed account: Rekeyed Account
 *          - If Watch account: Watch Account
 *          - else: empty field
 */
@Parcelize
class AccountDisplayName(
    private val accountAddress: String,
    private val accountName: String?,
    private val nfDomainName: String?,
    private val accountType: Account.Type?
) : Parcelable {

    private val accountShortenedName: String
        get() = accountAddress.toShortenedAddress()

    private val safeAccountName: String
        get() = accountName.orEmpty()

    private val safeNfDomainName: String
        get() = nfDomainName.orEmpty()

    private val isAccountRenamed: Boolean
        get() = safeAccountName != accountShortenedName

    private val isAccountMatchedNfDomain: Boolean
        get() = safeNfDomainName.isNotBlank()

    fun getRawAccountAddress(): String {
        return accountAddress
    }

    fun getAccountPrimaryDisplayName(): String {
        return when {
            isAccountRenamed -> safeAccountName
            isAccountMatchedNfDomain -> safeNfDomainName
            else -> accountShortenedName
        }
    }

    fun getAccountSecondaryDisplayName(resource: Resources): String? {
        return when {
            isAccountRenamed && isAccountMatchedNfDomain -> safeNfDomainName
            isAccountRenamed || isAccountMatchedNfDomain -> accountShortenedName
            else -> getAccountTypeName(resource)
        }
    }

    private fun getAccountTypeName(resources: Resources): String? {
        return when (accountType) {
            LEDGER -> R.string.ledger_account
            REKEYED -> R.string.rekeyed_account
            REKEYED_AUTH -> R.string.rekeyed_account
            WATCH -> R.string.watch_account
            else -> null
        }?.run { resources.getString(this) }
    }
}
