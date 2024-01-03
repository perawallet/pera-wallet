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

package com.algorand.android.modules.sorting.accountsorting.domain.usecase

import com.algorand.android.modules.sorting.accountsorting.domain.model.AccountSortingType
import com.algorand.android.modules.sorting.accountsorting.domain.repository.AccountSortPreferenceRepository
import javax.inject.Inject
import javax.inject.Named

class AccountSortPreferenceUseCase @Inject constructor(
    @Named(AccountSortPreferenceRepository.INJECTION_NAME)
    private val accountSortPreferenceRepository: AccountSortPreferenceRepository
) {

    suspend fun getAccountSortPreference(): AccountSortingType {
        val accountSortPreference = accountSortPreferenceRepository.getAccountSortPreference()
        return AccountSortingType.getSortTypeByIdentifier(accountSortPreference)
    }

    suspend fun saveAccountSortPreferences(accountSortTypeIdentifierAccount: AccountSortingType.TypeIdentifier) {
        accountSortPreferenceRepository.saveAccountSortPreference(accountSortTypeIdentifierAccount)
    }
}
