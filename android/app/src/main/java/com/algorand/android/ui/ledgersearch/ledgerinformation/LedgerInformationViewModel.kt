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

package com.algorand.android.ui.ledgersearch.ledgerinformation

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.usecase.LedgerInformationUseCase
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class LedgerInformationViewModel @ViewModelInject constructor(
    private val ledgerInformationUseCase: LedgerInformationUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val selectedLedger =
        savedStateHandle.getOrThrow<AccountSelectionListItem.AccountItem>(SELECTED_LEDGER_ACCOUNT_KEY)
    private val authLedger = savedStateHandle.get<AccountSelectionListItem.AccountItem?>(AUTH_LEDGER_ACCOUNT_KEY)
    private val rekeyedAccounts =
        savedStateHandle.get<Array<AccountSelectionListItem.AccountItem>?>(REKEYED_ACCOUNT_KEY)

    private val _ledgerInformationFlow = MutableStateFlow<List<LedgerInformationListItem>?>(null)
    val ledgerInformationFlow: StateFlow<List<LedgerInformationListItem>?> = _ledgerInformationFlow

    init {
        fetchLedgerInformationList()
    }

    private fun fetchLedgerInformationList() {
        viewModelScope.launch {
            val ledgerInformationList = ledgerInformationUseCase.getLedgerInformationListItem(
                selectedLedger,
                rekeyedAccounts?.toList(),
                authLedger
            )
            _ledgerInformationFlow.emit(ledgerInformationList)
        }
    }

    companion object {
        private const val SELECTED_LEDGER_ACCOUNT_KEY = "selectedLedgerAccountSelectionListItem"
        private const val AUTH_LEDGER_ACCOUNT_KEY = "authLedgerAccountSelectionListItem"
        private const val REKEYED_ACCOUNT_KEY = "rekeyedAccountSelectionListItem"
    }
}
