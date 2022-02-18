/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.Account
import com.algorand.android.repository.AccountRepository
import javax.inject.Inject

class AccountOptionsUseCase @Inject constructor(
    private val accountRepository: AccountRepository,
    private val accountDetailUseCase: AccountDetailUseCase
) : BaseUseCase() {

    fun isThereAnyAsset(publicKey: String): Boolean {
        val accountInformation = accountRepository.getCachedAccountDetail(publicKey)?.data?.accountInformation
        return accountInformation?.isThereAnyDifferentAsset() ?: false
    }

    fun isAccountRekeyed(publicKey: String): Boolean {
        return accountDetailUseCase.isAccountRekeyed(publicKey)
    }

    fun getAuthAddress(publicKey: String): String? {
        return accountDetailUseCase.getAuthAddress(publicKey)
    }

    fun getAccountAddress(publicKey: String): String? {
        return accountDetailUseCase.getAccountAddress(publicKey)
    }

    fun getAccountType(publicKey: String): Account.Type {
        return accountDetailUseCase.getAccountType(publicKey)
    }

    fun getAccountName(publicKey: String): String {
        return accountDetailUseCase.getAccountName(publicKey)
    }
}
