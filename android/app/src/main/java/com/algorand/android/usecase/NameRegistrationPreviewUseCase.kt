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
import com.algorand.android.mapper.NameRegistrationPreviewMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCreation
import com.algorand.android.models.ui.NameRegistrationPreview
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject

class NameRegistrationPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountUpdateUseCase: AccountUpdateUseCase,
    private val nameRegistrationPreviewMapper: NameRegistrationPreviewMapper,
    private val accountAdditionUseCase: AccountAdditionUseCase
) : BaseUseCase() {

    fun getInitialPreview(): NameRegistrationPreview {
        return nameRegistrationPreviewMapper.mapToInitialPreview()
    }

    fun getPreviewWithAccountCreation(accountCreation: AccountCreation?, inputName: String): NameRegistrationPreview? {
        accountCreation?.tempAccount?.let { account ->
            val address = account.address
            val accountName = inputName.ifBlank { address.toShortenedAddress() }
            account.name = accountName
            val doesAccountAlreadyExists = isThereAnyAccountWithThisAddress(address)
            if (doesAccountAlreadyExists.not()) {
                return nameRegistrationPreviewMapper.mapToCreateAccountPreview(accountCreation)
            }
            if (shouldUpdateWatchAccountEvent(address, accountCreation.creationType)) {
                return nameRegistrationPreviewMapper.mapToUpdateWatchAccountPreview(accountCreation)
            }
            return nameRegistrationPreviewMapper.mapToAccountAlreadyExistsPreview()
        }
        return null
    }

    suspend fun updateTypeOfWatchAccount(accountCreation: AccountCreation) {
        with(accountCreation.tempAccount) {
            val updatedType = type ?: return
            val updatedDetail = detail ?: return
            accountUpdateUseCase.updateAccountType(address = address, type = updatedType, detail = updatedDetail)
        }
    }

    fun updateNameOfWatchAccount(accountCreation: AccountCreation) {
        with(accountCreation.tempAccount) {
            accountUpdateUseCase.updateAccountName(address = address, newAccountName = name)
        }
    }

    fun getOnWatchAccountUpdatedPreview(): NameRegistrationPreview {
        return nameRegistrationPreviewMapper.mapToWatchAccountUpdatedPreview()
    }

    fun addNewAccount(account: Account, creationType: CreationType?) {
        accountAdditionUseCase.addNewAccount(account, creationType)
    }

    private fun isThereAnyAccountWithThisAddress(address: String): Boolean {
        return accountDetailUseCase.isThereAnyAccountWithPublicKey(address)
    }

    private fun isThereAWatchAccountWithThisAddress(address: String): Boolean {
        return accountDetailUseCase.getAccountType(address) == Account.Type.WATCH
    }

    private fun shouldUpdateWatchAccountEvent(address: String, creationType: CreationType): Boolean {
        val doesAccountExistAsWatchAccount = isThereAWatchAccountWithThisAddress(address)
        return doesAccountExistAsWatchAccount && creationType != CreationType.WATCH
    }
}
