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

package com.algorand.android.modules.baseledgeraccountselection.accountinformation.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.usecase.LedgerInformationUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class LedgerAccountInformationViewModel @Inject constructor(
    private val ledgerInformationUseCase: LedgerInformationUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val navArgs = LedgerAccountInformationBottomSheetArgs.fromSavedStateHandle(savedStateHandle)
    private val selectedLedger = navArgs.selectedLedgerAccountSelectionListItem
    private val authLedger = navArgs.authLedgerAccountSelectionListItem
    private val rekeyedAccounts = navArgs.rekeyedAccountSelectionListItem

    private val _ledgerInformationFlow = MutableStateFlow<List<LedgerInformationListItem>?>(null)
    val ledgerInformationFlow: StateFlow<List<LedgerInformationListItem>?> = _ledgerInformationFlow

    init {
        fetchLedgerInformationList()
    }

    private fun fetchLedgerInformationList() {
        viewModelScope.launchIO {
            val ledgerInformationList = ledgerInformationUseCase.getLedgerInformationListItem(
                selectedLedgerAccount = selectedLedger,
                rekeyedAccountSelectionListItem = rekeyedAccounts?.toList(),
                authLedgerAccount = authLedger
            )
            _ledgerInformationFlow.emit(ledgerInformationList)
        }
    }
}
