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

package com.algorand.android.modules.accounts.domain.usecase

import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.isEqualOrLesserThan
import com.algorand.android.utils.isGreaterThan
import java.math.BigDecimal
import javax.inject.Inject

class AccountBackupStatusUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val getAccountValueUseCase: GetAccountValueUseCase
) {

    fun getNotBackedUpAccounts(): List<String> {
        var accounts = mutableListOf<String>()
        accountDetailUseCase.getCachedAccountDetails().forEach { cachedAccountDetail ->
            cachedAccountDetail.data?.let { accountDetail ->
                if (accountDetail.account.isBackedUp) {
                    return@forEach
                }
                val publicKey = accountDetail.account.address
                val hasAnyRekeyedAccounts = accountDetailUseCase.getRekeyedAccountAddresses(publicKey).isNotEmpty()
                val accountValue = getAccountValueUseCase.getAccountValue(accountDetail).primaryAccountValue
                val hasBalance = accountValue.isGreaterThan(BigDecimal.ZERO)

                if (hasAnyRekeyedAccounts || hasBalance) {
                    accounts.add(publicKey)
                }
            }
        }
        return accounts
    }

    fun isAccountBackedUp(publicKey: String): Boolean {
        val cachedAccountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)
        cachedAccountDetail?.data?.let { accountDetail ->
            val accountValue = getAccountValueUseCase.getAccountValue(accountDetail)
            return accountValue.primaryAccountValue.isEqualOrLesserThan(BigDecimal.ZERO) ||
                    accountDetail.account.isBackedUp
        }
        return true
    }
}
