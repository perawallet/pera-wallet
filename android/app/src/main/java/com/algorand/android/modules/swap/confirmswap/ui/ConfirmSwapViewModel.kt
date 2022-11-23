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

package com.algorand.android.modules.swap.confirmswap.ui

import android.content.res.Resources
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.confirmswap.ui.model.ConfirmSwapPreview
import com.algorand.android.modules.swap.confirmswap.ui.usecase.ConfirmSwapPreviewUseCase
import com.algorand.android.modules.tracking.swap.confirmswap.ConfirmSwapConfirmClickEventTracker
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class ConfirmSwapViewModel @Inject constructor(
    private val confirmSwapPreviewUseCase: ConfirmSwapPreviewUseCase,
    private val confirmClickEventTracker: ConfirmSwapConfirmClickEventTracker,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private var _swapQuote = savedStateHandle.getOrThrow<SwapQuote>(SWAP_QUOTE_KEY)
    val swapQuote: SwapQuote
        get() = _swapQuote

    private val _confirmSwapPreviewFlow = MutableStateFlow(confirmSwapPreviewUseCase.getConfirmSwapPreview(swapQuote))
    val confirmSwapPreviewFlow: StateFlow<ConfirmSwapPreview>
        get() = _confirmSwapPreviewFlow

    fun getSwitchedPriceRatio(resources: Resources): AnnotatedString {
        return _confirmSwapPreviewFlow.value.getSwitchedPriceRatio(resources)
    }

    fun setupSwapTransactionSignManager(lifecycle: Lifecycle) {
        confirmSwapPreviewUseCase.setupSwapTransactionSignManager(lifecycle)
    }

    fun getSlippageTolerance() = _swapQuote.slippage

    fun onSlippageToleranceUpdated(slippageTolerance: Float) {
        viewModelScope.launch {
            confirmSwapPreviewUseCase.updateSlippageTolerance(
                slippageTolerance = slippageTolerance,
                swapQuote = swapQuote,
                previousState = _confirmSwapPreviewFlow.value
            ).collectLatest { newPreview ->
                _swapQuote = newPreview.swapQuote
                _confirmSwapPreviewFlow.value = newPreview
            }
        }
    }

    fun onConfirmSwapClick() {
        viewModelScope.launch {
            confirmClickEventTracker.logConfirmSwapClickEvent()
            confirmSwapPreviewUseCase.createQuoteAndUpdateUi(
                quoteId = swapQuote.quoteId,
                accountAddress = swapQuote.accountAddress.orEmpty(),
                previousState = _confirmSwapPreviewFlow.value
            ).collectLatest { newState ->
                _confirmSwapPreviewFlow.emit(newState)
            }
        }
    }

    fun onLedgerDialogCancelled() {
        confirmSwapPreviewUseCase.stopAllResources()
    }

    companion object {
        private const val SWAP_QUOTE_KEY = "swapQuote"
    }
}
