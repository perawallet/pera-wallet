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

package com.algorand.android.ui.rekey

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.modules.onboarding.rekeyledger.ui.model.RekeyLedgerAccountSelectionPreview
import com.algorand.android.modules.onboarding.rekeyledger.ui.usecase.RekeyLedgerAccountSelectionPreviewUseCase
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
class RekeyLedgerAccountSelectionViewModel @Inject constructor(
    private val rekeyLedgerAccountSelectionPreviewUseCase: RekeyLedgerAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle,
) : LedgerAccountSelectionViewModel(rekeyLedgerAccountSelectionPreviewUseCase) {

    private val ledgerAccounts = savedStateHandle.getOrThrow<Array<AccountInformation>>(LEDGER_ACCOUNTS_INFORMATION_KEY)
    private val ledgerBluetoothAddress = savedStateHandle.getOrThrow<String>(LEDGER_BLUETOOTH_ADDRESS_KEY)
    val ledgerBluetoothName = savedStateHandle.getOrElse<String?>(LEDGER_BLUETOOTH_NAME_KEY, null)
    val rekeyAddressKey = savedStateHandle.getOrThrow<String>(REKEY_ADDRESS_KEY)

    private val _rekeyLedgerAccountSelectionPreviewFlow = MutableStateFlow<RekeyLedgerAccountSelectionPreview?>(
        null
    )
    val rekeyLedgerAccountSelectionPreviewFlow: StateFlow<RekeyLedgerAccountSelectionPreview?>
        get() = _rekeyLedgerAccountSelectionPreviewFlow

    override val accountSelectionList: List<AccountSelectionListItem>
        get() = rekeyLedgerAccountSelectionPreviewFlow.value?.accountSelectionListItems.orEmpty()

    init {
        getAccountSelectionListItems()
    }

    private fun getAccountSelectionListItems() {
        viewModelScope.launch(Dispatchers.IO) {
            rekeyLedgerAccountSelectionPreviewUseCase.getRekeyLedgerAccountSelectionPreview(
                ledgerAccountsInformation = ledgerAccounts,
                bluetoothAddress = ledgerBluetoothAddress,
                bluetoothName = ledgerBluetoothName
            ).collectLatest { preview ->
                _rekeyLedgerAccountSelectionPreviewFlow.emit(preview)
            }
        }
    }

    override fun onNewAccountSelected(accountItem: AccountSelectionListItem.AccountItem) {
        val preview = _rekeyLedgerAccountSelectionPreviewFlow.value ?: return
        val updatedPreview = rekeyLedgerAccountSelectionPreviewUseCase.getUpdatedPreviewAccordingToAccountSelection(
            previousPreview = preview,
            accountItem = accountItem
        )
        _rekeyLedgerAccountSelectionPreviewFlow.update { updatedPreview }
    }

    companion object {
        private const val LEDGER_ACCOUNTS_INFORMATION_KEY = "ledgerAccountsInformation"
        private const val LEDGER_BLUETOOTH_NAME_KEY = "bluetoothName"
        private const val LEDGER_BLUETOOTH_ADDRESS_KEY = "bluetoothAddress"
        private const val REKEY_ADDRESS_KEY = "rekeyAddress"
    }
}
