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

import com.algorand.android.models.Account
import com.algorand.android.usecase.BaseAccountOrderUseCase.Companion.NOT_INITIALIZED_ACCOUNT_INDEX
import com.algorand.android.usecase.StandardAccountOrderUseCase.Companion.STANDARD_ACCOUNT_START_INDEX
import com.algorand.android.usecase.WatchAccountOrderUseCase.Companion.WATCH_ACCOUNT_START_INDEX
import javax.inject.Inject

class AccountIndexMigrationHelper @Inject constructor() : BaseMigrationHelper<List<Account>> {

    override fun isMigrationNeeded(values: List<Account>): Boolean {
        return values.any { it.index == NOT_INITIALIZED_ACCOUNT_INDEX }
    }

    override fun getMigratedValues(values: List<Account>): List<Account> {
        val (standardAccounts, watchAccounts) = values.partition { it.type == Account.Type.STANDARD }
        val migratedStandardAccounts = getMigratedAccountList(standardAccounts, STANDARD_ACCOUNT_START_INDEX)
        val migratedWatchAccounts = getMigratedAccountList(watchAccounts, WATCH_ACCOUNT_START_INDEX)
        return migratedStandardAccounts + migratedWatchAccounts
    }

    private fun getMigratedAccountList(accountList: List<Account>, startIndex: Int): List<Account> {
        val (notIndexedAccounts, indexedAccounts) = accountList.partition { it.index == NOT_INITIALIZED_ACCOUNT_INDEX }
        val orderedAccountList = indexedAccounts.mapIndexed { index, account ->
            account.copy(index = index + startIndex)
        }
        val orderedAccountListSize = orderedAccountList.size
        val newlyIndexedAccounts = notIndexedAccounts.mapIndexed { index, account ->
            account.copy(index = orderedAccountListSize + index + startIndex)
        }
        return mutableListOf<Account>().apply {
            addAll(orderedAccountList)
            addAll(newlyIndexedAccounts)
        }
    }
}
