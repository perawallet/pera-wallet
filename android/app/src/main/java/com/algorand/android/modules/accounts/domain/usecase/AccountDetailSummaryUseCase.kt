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

import com.algorand.android.mapper.AccountSummaryMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.decider.AccountDetailDecider
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject

class AccountDetailSummaryUseCase @Inject constructor(
    private val accountSummaryMapper: AccountSummaryMapper,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountDetailDecider: AccountDetailDecider,
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    fun getAccountDetailSummary(accountAddress: String): AccountDetailSummary {
        val account = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data?.account
        return accountSummaryMapper.mapToAccountDetailSummary(
            accountDisplayName = getAccountDisplayNameUseCase.invoke(accountAddress),
            accountAddress = accountAddress,
            accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(accountAddress),
            accountTypeResId = accountDetailDecider.decideAccountTypeResId(account),
            shouldDisplayAccountType = when (account?.type) {
                Account.Type.LEDGER, Account.Type.WATCH -> false
                Account.Type.STANDARD -> !accountStateHelperUseCase.hasAccountValidSecretKey(account)
                Account.Type.REKEYED, Account.Type.REKEYED_AUTH, null -> true
            }
        )
    }

    fun getAccountDetailSummary(accountDetail: AccountDetail?): AccountDetailSummary? {
        val account = accountDetail?.account ?: return null
        return accountSummaryMapper.mapToAccountDetailSummary(
            accountDisplayName = getAccountDisplayNameUseCase.invoke(account.address),
            accountAddress = account.address,
            accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(account.address),
            accountTypeResId = accountDetailDecider.decideAccountTypeResId(account),
            shouldDisplayAccountType = when (account.type) {
                Account.Type.LEDGER, Account.Type.WATCH -> false
                Account.Type.STANDARD -> !accountStateHelperUseCase.hasAccountValidSecretKey(account)
                Account.Type.REKEYED, Account.Type.REKEYED_AUTH, null -> true
            }
        )
    }
}
