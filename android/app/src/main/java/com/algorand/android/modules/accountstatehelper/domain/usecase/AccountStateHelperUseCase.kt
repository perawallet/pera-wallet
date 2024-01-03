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

package com.algorand.android.modules.accountstatehelper.domain.usecase

import com.algorand.android.models.Account
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject

class AccountStateHelperUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase
) {

    fun hasAccountValidSecretKey(account: Account?): Boolean {
        return with(account?.getSecretKey()) { this != null && isNotEmpty() }
    }

    fun hasAccountAuthority(account: Account?): Boolean {
        return when (account?.type) {
            Account.Type.STANDARD -> hasAccountValidSecretKey(account)
            Account.Type.LEDGER, Account.Type.REKEYED_AUTH -> true
            Account.Type.WATCH -> false
            Account.Type.REKEYED -> isAuthAccountInDevice(account.address)
            null -> false
        }
    }

    fun hasAccountAuthority(accountAddress: String): Boolean {
        val account = accountDetailUseCase.getAccount(accountAddress)
        return when (account?.type) {
            Account.Type.STANDARD -> hasAccountValidSecretKey(account)
            Account.Type.LEDGER, Account.Type.REKEYED_AUTH -> true
            Account.Type.WATCH -> false
            Account.Type.REKEYED -> isAuthAccountInDevice(account.address)
            null -> false
        }
    }

    private fun isAuthAccountInDevice(accountAddress: String): Boolean {
        val accountAuthAddress = accountDetailUseCase.getAuthAddress(accountAddress) ?: return false
        val authAccountDetail = accountDetailUseCase.getCachedAccountDetail(accountAuthAddress)?.data ?: return false
        return hasAccountAuthority(authAccountDetail.account.address)
    }
}
