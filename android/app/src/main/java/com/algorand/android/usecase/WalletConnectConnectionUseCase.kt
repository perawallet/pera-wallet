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

package com.algorand.android.usecase

import com.algorand.android.mapper.AccountSelectionMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountSelection
import javax.inject.Inject

class WalletConnectConnectionUseCase @Inject constructor(
    private val splittedAccountsUseCase: SplittedAccountsUseCase,
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase,
    private val accountSelectionMapper: AccountSelectionMapper
) {

    fun getNormalAccounts(): List<AccountSelection> {
        val normalAccounts = getCachedNormalAccounts()
        return normalAccounts.map { accountDetail ->
            val accountBalance = accountTotalBalanceUseCase.getAccountBalance(accountDetail)
            accountSelectionMapper.mapToAccountSelection(
                accountDetail = accountDetail,
                assetCount = accountBalance.assetCount,
                assetId = null,
                formattedAccountBalance = null
            )
        }
    }

    private fun getCachedNormalAccounts(): List<AccountDetail> {
        val (normalAccounts, _) = splittedAccountsUseCase.getWatchAccountSplittedAccountDetails()
        return normalAccounts.mapNotNull { it.data }
    }
}
