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

package com.algorand.android.ui.send.confirmation.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.ui.send.confirmation.ui.model.TransactionStatusPreview
import com.algorand.android.ui.send.confirmation.ui.usecase.TransactionConfirmationPreviewUseCase
import com.algorand.android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class TransactionConfirmationViewModel @Inject constructor(
    private val transactionConfirmationPreviewUseCase: TransactionConfirmationPreviewUseCase
) : BaseViewModel() {

    private val _transactionStatusPreviewFlow = MutableStateFlow<TransactionStatusPreview>(
        transactionConfirmationPreviewUseCase.getTransactionLoadingPreview()
    )
    val transactionStatusPreviewFlow: StateFlow<TransactionStatusPreview> = _transactionStatusPreviewFlow

    fun onTransactionIsLoaded() {
        viewModelScope.launch {
            _transactionStatusPreviewFlow.emit(transactionConfirmationPreviewUseCase.getTransactionReceivedPreview())
            onTransactionReceived()
        }
    }

    fun onTransactionReceived() {
        viewModelScope.launch {
            delay(NAV_BACK_DURATION)
            val currentPreview = _transactionStatusPreviewFlow.value
            _transactionStatusPreviewFlow.emit(currentPreview.copy(onExitSendAlgoNavigationEvent = Event(Unit)))
        }
    }

    companion object {
        private const val NAV_BACK_DURATION = 2000L
    }
}
