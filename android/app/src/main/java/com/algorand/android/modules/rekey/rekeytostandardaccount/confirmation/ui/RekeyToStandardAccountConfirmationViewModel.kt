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
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.model.RekeyToStandardAccountConfirmationPreview
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.usecase.RekeyToStandardAccountConfirmationPreviewUseCase
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class RekeyToStandardAccountConfirmationViewModel @Inject constructor(
    private val rekeyToStandardAccountConfirmationPreviewUseCase: RekeyToStandardAccountConfirmationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)
    val authAccountAddress = savedStateHandle.getOrThrow<String>(AUTH_ACCOUNT_ADDRESS_KEY)

    private val _rekeyToStandardAccountConfirmationPreviewFlow = MutableStateFlow(getInitialPreview())
    val rekeyToStandardAccountConfirmationPreviewFlow: StateFlow<RekeyToStandardAccountConfirmationPreview>
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

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        private const val AUTH_ACCOUNT_ADDRESS_KEY = "authAccountAddress"
    }
}
