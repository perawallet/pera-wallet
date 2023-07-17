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

import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import javax.inject.Inject

class AccountTypeUpdateHelper @Inject constructor(
    private val accountManager: AccountManager
) {

    /**
     * If user adds an account (which is rekeyed) with the passphrase, app creates this account as Standard account.
     * This function checks if account is rekeyed, if it is, then it updates Standard type as Rekeyed
     * and returns updated AccountDetail
     */
    suspend fun correctAccountTypeIfNeed(accountDetail: AccountDetail): AccountDetail {
        return with(accountDetail) {
            val isRekeyed = accountInformation.isRekeyed()
            when {
                account.type == Account.Type.STANDARD && isRekeyed -> {
                    val newType = Account.Type.REKEYED
                    val newDetail = Account.Detail.Rekeyed(account.getSecretKey())
                    accountManager.changeAccountType(account.address, newType, newDetail)
                    copy(account = account.copy(type = newType, detail = newDetail))
                }
                account.type == Account.Type.REKEYED && !isRekeyed -> {
                    val newType = Account.Type.STANDARD
                    val newDetail = Account.Detail.Standard(account.getSecretKey() ?: byteArrayOf())
                    accountManager.changeAccountType(account.address, newType, newDetail)
                    copy(account = account.copy(type = newType, detail = newDetail))
                }
                account.type == Account.Type.LEDGER && account.detail is Account.Detail.Ledger && isRekeyed -> {
                    val newType = Account.Type.REKEYED
                    val newDetail = Account.Detail.Rekeyed(secretKey = account.getSecretKey())
                    accountManager.changeAccountType(account.address, newType, newDetail)
                    copy(account = account.copy(type = newType, detail = newDetail))
                }
                else -> this
            }
        }
    }
}
