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

import com.algorand.android.core.AccountManager
import com.algorand.android.mapper.AccountOrderItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.ui.AccountOrderItem
import javax.inject.Inject

class WatchAccountOrderUseCase @Inject constructor(
    override val accountManager: AccountManager,
    accountOrderItemMapper: AccountOrderItemMapper
) : BaseAccountOrderUseCase(accountManager, accountOrderItemMapper) {

    override val defaultAccountType: Account.Type
        get() = Account.Type.WATCH

    override fun getFilteredAccounts(): List<Account> {
        return accountManager.getAccounts().filter { it.type == Account.Type.WATCH }
    }

    override fun saveAccountsWithSelectedOrder(accountOrderList: List<AccountOrderItem>) {
        val (standardAccounts, watchAccounts) = accountManager.getAccounts().partition { it.type != Account.Type.WATCH }
        val orderedWatchAccountList = accountOrderList.mapIndexedNotNull { index, accountOrderItem ->
            watchAccounts.firstOrNull { it.address == accountOrderItem.publicKey }
                ?.copy(index = index + WATCH_ACCOUNT_START_INDEX)
        }
        accountManager.saveAccounts(standardAccounts + orderedWatchAccountList)
    }

    companion object {
        const val WATCH_ACCOUNT_START_INDEX = 10000
    }
}
