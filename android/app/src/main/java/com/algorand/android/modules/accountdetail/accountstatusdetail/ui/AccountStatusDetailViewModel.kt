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

package com.algorand.android.modules.accountdetail.accountstatusdetail.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.accountdetail.accountstatusdetail.ui.model.AccountStatusDetailPreview
import com.algorand.android.modules.accountdetail.accountstatusdetail.ui.usecase.AccountStatusDetailPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update

@HiltViewModel
class AccountStatusDetailViewModel @Inject constructor(
    private val accountStatusDetailPreviewUseCase: AccountStatusDetailPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val navArgs = AccountStatusDetailBottomSheetArgs.fromSavedStateHandle(savedStateHandle)
    val accountAddress = navArgs.accountAddress
    val authAccountAddress: String
        get() = _accountStatusDetailPreviewFlow.value?.authAccountDisplayName?.getRawAccountAddress().orEmpty()

    private val _accountStatusDetailPreviewFlow = MutableStateFlow<AccountStatusDetailPreview?>(null)
    val accountStatusDetailPreviewFlow: StateFlow<AccountStatusDetailPreview?> get() = _accountStatusDetailPreviewFlow

    init {
        initAccountStatusDetailPreview()
    }

    private fun initAccountStatusDetailPreview() {
        viewModelScope.launchIO {
            accountStatusDetailPreviewUseCase.getAccountStatusDetailPreviewFlow(
                accountAddress = accountAddress
            ).collectLatest { preview ->
                _accountStatusDetailPreviewFlow.emit(preview)
            }
        }
    }

    fun onAuthAccountActionButtonClicked() {
        _accountStatusDetailPreviewFlow.update { preview ->
            accountStatusDetailPreviewUseCase.updatePreviewWithUndoRekeyNavigationEvent(preview)
        }
    }

    fun onAccountActionButtonClicked() {
        _accountStatusDetailPreviewFlow.update { preview ->
            accountStatusDetailPreviewUseCase.updatePreviewWithAddressCopyEvent(preview)
        }
    }
}
