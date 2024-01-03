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

package com.algorand.android.modules.sorting.accountsorting.data.repository

import com.algorand.android.modules.sorting.accountsorting.data.local.AccountSortPreferencesLocalSource
import com.algorand.android.modules.sorting.accountsorting.domain.model.AccountSortingType.TypeIdentifier
import com.algorand.android.modules.sorting.accountsorting.domain.repository.AccountSortPreferenceRepository
import javax.inject.Inject

class AccountSortPreferenceRepositoryImpl @Inject constructor(
    private val accountSortPreferencesLocalSource: AccountSortPreferencesLocalSource
) : AccountSortPreferenceRepository {

    override suspend fun saveAccountSortPreference(accountSortTypeIdentifierAccount: TypeIdentifier) {
        accountSortPreferencesLocalSource.saveData(accountSortTypeIdentifierAccount.name)
    }

    override suspend fun getAccountSortPreference(): TypeIdentifier? {
        return TypeIdentifier.values().firstOrNull {
            it.name == accountSortPreferencesLocalSource.getDataOrNull()
        }
    }
}
