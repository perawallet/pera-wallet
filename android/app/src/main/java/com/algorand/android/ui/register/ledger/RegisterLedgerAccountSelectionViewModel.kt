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

package com.algorand.android.ui.register.ledger

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.modules.onboarding.pairledger.ui.model.RegisterLedgerAccountSelectionPreview
import com.algorand.android.modules.onboarding.pairledger.ui.usecase.RegisterLedgerAccountSelectionPreviewUseCase
import com.algorand.android.ui.ledgeraccountselection.LedgerAccountSelectionViewModel
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class RegisterLedgerAccountSelectionViewModel @Inject constructor(
    private val registerLedgerAccountSelectionPreviewUseCase: RegisterLedgerAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : LedgerAccountSelectionViewModel(registerLedgerAccountSelectionPreviewUseCase) {

    private val ledgerAccounts = savedStateHandle.getOrThrow<Array<AccountInformation>>(LEDGER_ACCOUNTS_INFORMATION_KEY)
    private val ledgerBluetoothAddress = savedStateHandle.getOrThrow<String>(LEDGER_BLUETOOTH_ADDRESS_KEY)
    val ledgerBluetoothName = savedStateHandle.getOrElse<String?>(LEDGER_BLUETOOTH_NAME_KEY, null)

    private val _registerLedgerAccountSelectionPreviewFlow = MutableStateFlow<RegisterLedgerAccountSelectionPreview?>(
        null
    )
    val registerLedgerAccountSelectionPreviewFlow: StateFlow<RegisterLedgerAccountSelectionPreview?>
        get() = _registerLedgerAccountSelectionPreviewFlow

    override val accountSelectionList: List<AccountSelectionListItem>
        get() = registerLedgerAccountSelectionPreviewFlow.value?.accountSelectionListItems.orEmpty()

    init {
        getAccountSelectionListItems()
    }

    private fun getAccountSelectionListItems() {
        viewModelScope.launch(Dispatchers.IO) {
            registerLedgerAccountSelectionPreviewUseCase.getRegisterLedgerAccountSelectionPreview(
                ledgerAccountsInformation = ledgerAccounts,
                bluetoothAddress = ledgerBluetoothAddress,
                bluetoothName = ledgerBluetoothName
            ).collectLatest { preview ->
                _registerLedgerAccountSelectionPreviewFlow.emit(preview)
            }
        }
    }

    override fun onNewAccountSelected(accountItem: AccountSelectionListItem.AccountItem) {
        val preview = _registerLedgerAccountSelectionPreviewFlow.value ?: return
        val updatedPreview = registerLedgerAccountSelectionPreviewUseCase.getUpdatedPreviewAccordingToAccountSelection(
            previousPreview = preview,
            accountItem = accountItem
        )
        _registerLedgerAccountSelectionPreviewFlow.update { updatedPreview }
    }

    companion object {
        private const val LEDGER_ACCOUNTS_INFORMATION_KEY = "ledgerAccountsInformation"
        private const val LEDGER_BLUETOOTH_NAME_KEY = "bluetoothName"
        private const val LEDGER_BLUETOOTH_ADDRESS_KEY = "bluetoothAddress"
    }
}
