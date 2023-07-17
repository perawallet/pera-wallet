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

import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.repository.ContactRepository
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject

class AccountNameIconUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val contactRepository: ContactRepository,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) {

    fun getAccountDisplayTextAndIcon(accountAddress: String): Pair<String, AccountIconDrawablePreview> {
        return with(accountDetailUseCase) {
            getAccountName(accountAddress) to createAccountIconDrawableUseCase.invoke(accountAddress)
        }
    }

    suspend fun getAccountOrContactDisplayTextAndIcon(
        accountAddress: String
    ): Pair<String, AccountIconDrawablePreview?> {
        val localReceiver = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data
        if (localReceiver != null) {
            val accountName = accountDetailUseCase.getAccountName(accountAddress)
            val accountIcon = createAccountIconDrawableUseCase.invoke(accountAddress)
            return accountName to accountIcon
        }
        val contactReceiver = contactRepository.getAllContacts().firstOrNull { it.publicKey == accountAddress }
        return (contactReceiver?.name ?: accountAddress.toShortenedAddress()) to null
    }
}
