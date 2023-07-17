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

package com.algorand.android.modules.rekey.undorekey.confirmation.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.BaseRekeyConfirmationViewModel
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.model.BaseRekeyConfirmationFields
import com.algorand.android.modules.rekey.undorekey.confirmation.ui.model.UndoRekeyConfirmationPreview
import com.algorand.android.modules.rekey.undorekey.confirmation.ui.usecase.UndoRekeyConfirmationPreviewUseCase
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
class UndoRekeyConfirmationViewModel @Inject constructor(
    private val undoRekeyConfirmationPreviewUseCase: UndoRekeyConfirmationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseRekeyConfirmationViewModel() {

    private val navArgs = UndoRekeyConfirmationFragmentArgs.fromSavedStateHandle(savedStateHandle)
    val accountAddress = navArgs.accountAddress

    private val _undoRekeyConfirmationPreviewFlow = MutableStateFlow(getInitialPreview())
    override val baseRekeyConfirmationFieldsFlow: StateFlow<BaseRekeyConfirmationFields>
        get() = _undoRekeyConfirmationPreviewFlow

    private var sendTransactionJob: Job? = null

    init {
        updatePreviewWithCalculatedTransactionFee()
    }

    fun createRekeyToStandardAccountTransaction(): TransactionData? {
        return undoRekeyConfirmationPreviewUseCase.createUndoRekeyTransaction(
            accountAddress = accountAddress
        )
    }

    fun onTransactionSigningFailed() {
        _undoRekeyConfirmationPreviewFlow.update { preview ->
            undoRekeyConfirmationPreviewUseCase.updatePreviewWithClearLoadingState(preview)
        }
    }

    fun onTransactionSigningStarted() {
        _undoRekeyConfirmationPreviewFlow.update { preview ->
            undoRekeyConfirmationPreviewUseCase.updatePreviewWithLoadingState(preview)
        }
    }

    fun sendRekeyTransaction(transactionDetail: SignedTransactionDetail) {
        if (sendTransactionJob?.isActive == true) {
            return
        }
        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            undoRekeyConfirmationPreviewUseCase.sendUndoRekeyTransaction(
                transactionDetail = transactionDetail,
                preview = _undoRekeyConfirmationPreviewFlow.value
            ).collectLatest { preview ->
                _undoRekeyConfirmationPreviewFlow.emit(preview)
            }
        }
    }

    fun onConfirmRekeyClick() {
        _undoRekeyConfirmationPreviewFlow.update { preview ->
            undoRekeyConfirmationPreviewUseCase.updatePreviewWithRekeyConfirmationClick(
                accountAddress = accountAddress,
                preview = preview
            )
        }
    }

    fun getAccountAuthAddress(): String {
        return undoRekeyConfirmationPreviewUseCase.getAccountAuthAddress(accountAddress)
    }

    private fun getInitialPreview(): UndoRekeyConfirmationPreview {
        return undoRekeyConfirmationPreviewUseCase.getInitialUndoRekeyConfirmationPreview(accountAddress)
    }

    private fun updatePreviewWithCalculatedTransactionFee() {
        viewModelScope.launchIO {
            undoRekeyConfirmationPreviewUseCase.updatePreviewWithTransactionFee(
                preview = _undoRekeyConfirmationPreviewFlow.value
            ).collectLatest { preview ->
                _undoRekeyConfirmationPreviewFlow.emit(preview)
            }
        }
    }
}
