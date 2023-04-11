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

package com.algorand.android.modules.swap.transactionstatus.ui

import android.content.res.Resources
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusPreview
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusType
import com.algorand.android.modules.swap.transactionstatus.ui.usecase.SwapTransactionStatusPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class SwapTransactionStatusViewModel @Inject constructor(
    private val swapTransactionStatusPreviewUseCase: SwapTransactionStatusPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val args = SwapTransactionStatusFragmentArgs.fromSavedStateHandle(savedStateHandle)
    val swapQuote: SwapQuote
        get() = args.swapQuote

    private val _swapTransactionStatusPreviewFlow = MutableStateFlow<SwapTransactionStatusPreview?>(null)
    val swapTransactionStatusPreviewFlow: StateFlow<SwapTransactionStatusPreview?>
        get() = _swapTransactionStatusPreviewFlow

    fun getNetworkSlug(): String? {
        return swapTransactionStatusPreviewUseCase.getNetworkSlug()
    }

    fun onPrimaryButtonClicked(swapTransactionStatusType: SwapTransactionStatusType) {
        viewModelScope.launch {
            when (swapTransactionStatusType) {
                SwapTransactionStatusType.FAILED -> onTryAgainClick()
                SwapTransactionStatusType.COMPLETED -> onSwapDoneClick()
                SwapTransactionStatusType.SENDING -> Unit
            }
        }
    }

    fun initSwapTransactionStatusPreviewFlow(resources: Resources) {
        if (_swapTransactionStatusPreviewFlow.value == null)
            updateTransactionStatusPreviewFlow(resources)
    }

    private fun updateTransactionStatusPreviewFlow(resources: Resources) {
        viewModelScope.launch {
            swapTransactionStatusPreviewUseCase.getSwapTransactionStatusPreviewFlow(
                resources = resources,
                swapQuote = args.swapQuote,
                signedTransactions = args.swapQuoteTransaction
            ).collectLatest { preview ->
                _swapTransactionStatusPreviewFlow.emit(preview)
            }
        }
    }

    fun getOptInTransactionsFees(): Long {
        return swapTransactionStatusPreviewUseCase.getOptInTransactionFees(args.swapQuoteTransaction)
    }

    fun getAlgorandTransactionFees(): Long {
        return swapTransactionStatusPreviewUseCase.getAlgorandTransactionFees(args.swapQuoteTransaction)
    }

    private fun onSwapDoneClick() {
        _swapTransactionStatusPreviewFlow.value?.let { preview ->
            _swapTransactionStatusPreviewFlow.value = swapTransactionStatusPreviewUseCase
                .updatePreviewWithNavigateBack(preview)
        }
    }

    private fun onTryAgainClick() {
        _swapTransactionStatusPreviewFlow.value?.let { preview ->
            _swapTransactionStatusPreviewFlow.value = swapTransactionStatusPreviewUseCase
                .updatePreviewForTryAgain(preview)
        }
    }
}
