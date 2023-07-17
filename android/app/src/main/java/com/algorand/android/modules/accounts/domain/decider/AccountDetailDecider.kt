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

package com.algorand.android.modules.accounts.domain.decider

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import javax.inject.Inject

// TODO remove usecase from decider
class AccountDetailDecider @Inject constructor(
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    // TODO Make account non-nullable
    fun decideAccountTypeResId(account: Account?): Int {
        return when (account?.type) {
            Account.Type.LEDGER -> R.string.ledger
            Account.Type.WATCH -> R.string.watch
            Account.Type.STANDARD -> {
                val hasAccountValidSecretKey = accountStateHelperUseCase.hasAccountValidSecretKey(account)
                if (hasAccountValidSecretKey) R.string.standard else R.string.no_auth
            }

            Account.Type.REKEYED, Account.Type.REKEYED_AUTH, null -> {
                val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(account)
                if (hasAccountAuthority) R.string.rekeyed else R.string.no_auth
            }
        }
    }
}
