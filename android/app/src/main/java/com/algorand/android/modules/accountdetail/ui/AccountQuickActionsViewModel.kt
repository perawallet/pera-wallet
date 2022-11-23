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

package com.algorand.android.modules.accountdetail.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.accountdetail.ui.model.AccountQuickActionsPreview
import com.algorand.android.modules.accountdetail.ui.usecase.AccountQuickActionsPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class AccountQuickActionsViewModel @Inject constructor(
    private val accountQuickActionsPreviewUseCase: AccountQuickActionsPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val accountAddress: String = savedStateHandle.getOrThrow(ACCOUNT_ADDRESS_KEY)

    private val _accountQuickActionsPreviewFlow = MutableStateFlow<AccountQuickActionsPreview>(
        accountQuickActionsPreviewUseCase.getInitialPreview(accountAddress)
    )
    val accountQuickActionsPreviewFlow: StateFlow<AccountQuickActionsPreview>
        get() = _accountQuickActionsPreviewFlow

    fun onSwapClick() {
        viewModelScope.launch {
            _accountQuickActionsPreviewFlow.value = accountQuickActionsPreviewUseCase
                .getSwapNavigationUpdatedPreview(accountAddress, _accountQuickActionsPreviewFlow.value)
        }
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
