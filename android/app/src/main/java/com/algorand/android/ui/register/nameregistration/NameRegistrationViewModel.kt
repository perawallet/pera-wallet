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

package com.algorand.android.ui.register.nameregistration

import javax.inject.Inject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCreation
import com.algorand.android.usecase.IsAccountLimitExceedUseCase
import com.algorand.android.models.ui.NameRegistrationPreview
import com.algorand.android.usecase.NameRegistrationPreviewUseCase
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import dagger.hilt.android.lifecycle.HiltViewModel

@HiltViewModel
class NameRegistrationViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val nameRegistrationPreviewUseCase: NameRegistrationPreviewUseCase,
    private val isAccountLimitExceedUseCase: IsAccountLimitExceedUseCase
) : ViewModel() {

    private val _nameRegistrationPreviewFlow = MutableStateFlow(getInitialPreview())
    val nameRegistrationPreviewFlow: Flow<NameRegistrationPreview>
        get() = _nameRegistrationPreviewFlow

    val accountAddress = savedStateHandle.getOrThrow<AccountCreation>(ACCOUNT_CREATION_KEY).tempAccount.address

    fun updatePreviewWithAccountCreation(accountCreation: AccountCreation?, inputName: String) {
        viewModelScope.launch {
            nameRegistrationPreviewUseCase.getPreviewWithAccountCreation(
                accountCreation = accountCreation,
                inputName = inputName
            )?.let {
                _nameRegistrationPreviewFlow.emit(it)
            }
        }
    }

    fun updateWatchAccount(accountCreation: AccountCreation) {
        viewModelScope.launch {
            nameRegistrationPreviewUseCase.updateTypeOfWatchAccount(accountCreation)
            nameRegistrationPreviewUseCase.updateNameOfWatchAccount(accountCreation)
            _nameRegistrationPreviewFlow.emit(nameRegistrationPreviewUseCase.getOnWatchAccountUpdatedPreview())
        }
    }

    fun addNewAccount(account: Account, creationType: CreationType?) {
        // TODO: Handle error case
        nameRegistrationPreviewUseCase.addNewAccount(account, creationType)
    }

    private fun getInitialPreview(): NameRegistrationPreview {
        return nameRegistrationPreviewUseCase.getInitialPreview()
    }

    fun isAccountLimitExceed(): Boolean {
        return isAccountLimitExceedUseCase.isAccountLimitExceed()
    }

    companion object {
        private const val ACCOUNT_CREATION_KEY = "accountCreation"
    }
}
