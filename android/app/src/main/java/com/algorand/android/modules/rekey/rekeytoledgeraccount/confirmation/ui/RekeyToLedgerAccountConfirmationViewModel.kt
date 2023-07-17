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

package com.algorand.android.modules.rekey.rekeytoledgeraccount.confirmation.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.BaseRekeyConfirmationViewModel
import com.algorand.android.modules.rekey.rekeytoledgeraccount.confirmation.ui.model.RekeyToLedgerAccountConfirmationPreview
import com.algorand.android.modules.rekey.rekeytoledgeraccount.confirmation.ui.usecase.RekeyToLedgerAccountConfirmationPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class RekeyToLedgerAccountConfirmationViewModel @Inject constructor(
    private val rekeyToLedgerAccountConfirmationPreviewUseCase: RekeyToLedgerAccountConfirmationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseRekeyConfirmationViewModel() {

    private val navArgs = RekeyToLedgerAccountConfirmationFragmentArgs.fromSavedStateHandle(savedStateHandle)
    val accountAddress = navArgs.accountAddress
    val authAccountAddress = navArgs.authAccountAddress
    private val ledgerDetail = navArgs.ledgerDetail

    private var sendTransactionJob: Job? = null

    private val rekeyToLedgerAccountConfirmationPreviewFlow = MutableStateFlow(getInitialPreview())
    override val baseRekeyConfirmationFieldsFlow: StateFlow<RekeyToLedgerAccountConfirmationPreview>
        get() = rekeyToLedgerAccountConfirmationPreviewFlow

    init {
        updatePreviewWithCalculatedTransactionFee()
    }

    fun createRekeyToLedgerAccountTransaction(): TransactionData.Rekey? {
        return rekeyToLedgerAccountConfirmationPreviewUseCase.createRekeyToLedgerAccountTransaction(
            accountAddress = accountAddress,
            authAccountAddress = authAccountAddress,
            ledgerDetail = ledgerDetail
        )
    }

    fun onTransactionSigningFailed() {
        rekeyToLedgerAccountConfirmationPreviewFlow.update { preview ->
            rekeyToLedgerAccountConfirmationPreviewUseCase.updatePreviewWithClearLoadingState(preview)
        }
    }

    fun onTransactionSigningStarted() {
        rekeyToLedgerAccountConfirmationPreviewFlow.update { preview ->
            rekeyToLedgerAccountConfirmationPreviewUseCase.updatePreviewWithLoadingState(preview)
        }
    }

    fun sendRekeyTransaction(transactionDetail: SignedTransactionDetail.RekeyOperation) {
        if (sendTransactionJob?.isActive == true) {
            return
        }
        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            rekeyToLedgerAccountConfirmationPreviewUseCase.sendRekeyToLedgerAccountTransaction(
                transactionDetail = transactionDetail,
                preview = rekeyToLedgerAccountConfirmationPreviewFlow.value
            ).collectLatest { preview ->
                rekeyToLedgerAccountConfirmationPreviewFlow.emit(preview)
            }
        }
    }

    fun onConfirmRekeyClick() {
        rekeyToLedgerAccountConfirmationPreviewFlow.update { preview ->
            rekeyToLedgerAccountConfirmationPreviewUseCase.updatePreviewWithRekeyConfirmationClick(
                accountAddress = accountAddress,
                preview = preview
            )
        }
    }

    private fun getInitialPreview(): RekeyToLedgerAccountConfirmationPreview {
        return rekeyToLedgerAccountConfirmationPreviewUseCase.getInitialRekeyToStandardAccountConfirmationPreview(
            accountAddress = accountAddress,
            authAccountAddress = authAccountAddress
        )
    }

    private fun updatePreviewWithCalculatedTransactionFee() {
        viewModelScope.launchIO {
            rekeyToLedgerAccountConfirmationPreviewUseCase.updatePreviewWithTransactionFee(
                preview = rekeyToLedgerAccountConfirmationPreviewFlow.value
            ).collectLatest { preview ->
                rekeyToLedgerAccountConfirmationPreviewFlow.emit(preview)
            }
        }
    }
}
