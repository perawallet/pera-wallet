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

package com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.BaseRekeyConfirmationViewModel
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.model.BaseRekeyConfirmationFields
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.model.RekeyToStandardAccountConfirmationPreview
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.usecase.RekeyToStandardAccountConfirmationPreviewUseCase
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
class RekeyToStandardAccountConfirmationViewModel @Inject constructor(
    private val rekeyToStandardAccountConfirmationPreviewUseCase: RekeyToStandardAccountConfirmationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseRekeyConfirmationViewModel() {

    private val navArgs = RekeyToStandardAccountConfirmationFragmentArgs.fromSavedStateHandle(savedStateHandle)
    val accountAddress = navArgs.accountAddress
    val authAccountAddress = navArgs.authAccountAddress

    private val _rekeyToStandardAccountConfirmationPreviewFlow = MutableStateFlow(getInitialPreview())
    override val baseRekeyConfirmationFieldsFlow: StateFlow<BaseRekeyConfirmationFields>
        get() = _rekeyToStandardAccountConfirmationPreviewFlow

    private var sendTransactionJob: Job? = null

    init {
        updatePreviewWithCalculatedTransactionFee()
    }

    fun createRekeyToStandardAccountTransaction(): TransactionData.RekeyToStandardAccount? {
        return rekeyToStandardAccountConfirmationPreviewUseCase.createRekeyToStandardAccountTransaction(
            accountAddress = accountAddress,
            authAccountAddress = authAccountAddress,
        )
    }

    fun onTransactionSigningFailed() {
        _rekeyToStandardAccountConfirmationPreviewFlow.update { preview ->
            rekeyToStandardAccountConfirmationPreviewUseCase.updatePreviewWithClearLoadingState(preview)
        }
    }

    fun onTransactionSigningStarted() {
        _rekeyToStandardAccountConfirmationPreviewFlow.update { preview ->
            rekeyToStandardAccountConfirmationPreviewUseCase.updatePreviewWithLoadingState(preview)
        }
    }

    fun sendRekeyTransaction(transactionDetail: SignedTransactionDetail.RekeyToStandardAccountOperation) {
        if (sendTransactionJob?.isActive == true) {
            return
        }
        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            rekeyToStandardAccountConfirmationPreviewUseCase.sendRekeyToStandardAccountTransaction(
                transactionDetail = transactionDetail,
                preview = _rekeyToStandardAccountConfirmationPreviewFlow.value
            ).collectLatest { preview ->
                _rekeyToStandardAccountConfirmationPreviewFlow.emit(preview)
            }
        }
    }

    fun onConfirmRekeyClick() {
        _rekeyToStandardAccountConfirmationPreviewFlow.update { preview ->
            rekeyToStandardAccountConfirmationPreviewUseCase.updatePreviewWithRekeyConfirmationClick(
                accountAddress = accountAddress,
                preview = preview
            )
        }
    }

    private fun getInitialPreview(): RekeyToStandardAccountConfirmationPreview {
        return rekeyToStandardAccountConfirmationPreviewUseCase.getInitialRekeyToStandardAccountConfirmationPreview(
            accountAddress = accountAddress,
            authAccountAddress = authAccountAddress
        )
    }

    private fun updatePreviewWithCalculatedTransactionFee() {
        viewModelScope.launchIO {
            rekeyToStandardAccountConfirmationPreviewUseCase.updatePreviewWithTransactionFee(
                preview = _rekeyToStandardAccountConfirmationPreviewFlow.value
            ).collectLatest { preview ->
                _rekeyToStandardAccountConfirmationPreviewFlow.emit(preview)
            }
        }
    }
}
