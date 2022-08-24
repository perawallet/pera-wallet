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

@Parcelize
class AccountDisplayName private constructor(
    private val accountAddress: String,
    private val accountName: String,
    private val accountType: Account.Type? = null
) : Parcelable {

    fun getDisplayTextOrAccountShortenedAddress(): String {
        return accountName.ifBlank { getShortenedAddress() }
    }

    fun getAccountName(): String {
        return accountName
    }

    fun getAccountAddress(): String {
        return accountAddress
    }

    fun getShortenedAddress(): String {
        return accountAddress.toShortenedAddress()
    }

    fun getAccountShortenedAddressOrAccountType(resources: Resources): String? {
        val isAccountRenamed = getAccountName() != getShortenedAddress()
        return if (isAccountRenamed) {
            getShortenedAddress()
        } else {
            val typeNameRes = when (accountType) {
                LEDGER -> R.string.ledger_account
                REKEYED -> R.string.rekeyed_account
                REKEYED_AUTH -> R.string.rekeyed_account
                WATCH -> R.string.watch_account
                else -> null
            }
            resources.getString(typeNameRes ?: return null)
        }
    }

    companion object {
        fun create(accountAddress: String, accountName: String, type: Account.Type?): AccountDisplayName {
            return AccountDisplayName(accountAddress, accountName, type)
        }
    }
}
