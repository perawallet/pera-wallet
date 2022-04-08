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

import com.algorand.android.models.AccountIcon
import com.algorand.android.repository.ContactRepository
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject

class AccountNameIconUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val contactRepository: ContactRepository,
) {

    fun getAccountDisplayTextAndIcon(publicKey: String): Pair<String, AccountIcon?> {
        return with(accountDetailUseCase) {
            getAccountName(publicKey) to getAccountIcon(publicKey)
        }
    }

    suspend fun getAccountOrContactDisplayTextAndIcon(publicKey: String): Pair<String, AccountIcon?> {
        val localReceiver = accountDetailUseCase.getCachedAccountDetail(publicKey)?.data
        if (localReceiver != null) {
            return accountDetailUseCase.getAccountName(publicKey) to localReceiver.account.createAccountIcon()
        }
        val contactReceiver = contactRepository.getAllContacts().firstOrNull { it.publicKey == publicKey }
        return (contactReceiver?.name ?: publicKey.toShortenedAddress()) to null
    }
}
