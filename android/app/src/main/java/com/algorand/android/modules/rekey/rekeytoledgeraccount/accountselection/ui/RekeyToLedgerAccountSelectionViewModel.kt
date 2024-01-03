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

package com.algorand.android.modules.rekey.rekeytoledgeraccount.accountselection.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.BaseLedgerAccountSelectionViewModel
import com.algorand.android.modules.rekey.rekeytoledgeraccount.accountselection.ui.model.RekeyLedgerAccountSelectionPreview
import com.algorand.android.modules.rekey.rekeytoledgeraccount.accountselection.ui.usecase.RekeyLedgerAccountSelectionPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class RekeyToLedgerAccountSelectionViewModel @Inject constructor(
    private val rekeyLedgerAccountSelectionPreviewUseCase: RekeyLedgerAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle,
) : BaseLedgerAccountSelectionViewModel(rekeyLedgerAccountSelectionPreviewUseCase) {

    private val args = RekeyToLedgerAccountSelectionFragmentArgs.fromSavedStateHandle(savedStateHandle)

    val ledgerBluetoothName: String? = args.bluetoothName
    val accountAddress: String = args.accountAddress

    private val _rekeyLedgerAccountSelectionPreviewFlow = MutableStateFlow<RekeyLedgerAccountSelectionPreview?>(null)
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
                ledgerAccountsInformation = args.ledgerAccountsInformation,
                bluetoothAddress = args.bluetoothAddress,
                bluetoothName = args.bluetoothName,
                accountAddress = args.accountAddress
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
}
