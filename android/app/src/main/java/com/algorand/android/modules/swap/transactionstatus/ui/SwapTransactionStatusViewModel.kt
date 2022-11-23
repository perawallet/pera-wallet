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
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusPreview
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusType
import com.algorand.android.modules.swap.transactionstatus.ui.usecase.SwapTransactionStatusPreviewUseCase
import com.algorand.android.utils.getOrThrow
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

    private val signedTransactions = savedStateHandle.getOrThrow<Array<SwapQuoteTransaction>>(TRANSACTION_LIST_KEY)
    val swapQuote = savedStateHandle.getOrThrow<SwapQuote>(SWAP_QUOTE_KEY)

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
                resources,
                swapQuote,
                signedTransactions
            ).collectLatest { preview ->
                _swapTransactionStatusPreviewFlow.emit(preview)
            }
        }
    }

    fun getOptInTransactionsFees(): Long {
        return swapTransactionStatusPreviewUseCase.getOptInTransactionFees(signedTransactions)
    }

    fun getAlgorandTransactionFees(): Long {
        return swapTransactionStatusPreviewUseCase.getAlgorandTransactionFees(signedTransactions)
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

    companion object {
        private const val TRANSACTION_LIST_KEY = "swapQuoteTransaction"
        private const val SWAP_QUOTE_KEY = "swapQuote"
    }
}
