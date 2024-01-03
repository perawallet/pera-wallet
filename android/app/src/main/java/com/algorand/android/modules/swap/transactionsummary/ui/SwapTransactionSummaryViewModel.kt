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

package com.algorand.android.modules.swap.transactionsummary.ui

import android.content.res.Resources
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.transactionsummary.ui.model.SwapTransactionSummaryPreview
import com.algorand.android.modules.swap.transactionsummary.ui.usecase.SwapTransactionSummaryPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class SwapTransactionSummaryViewModel @Inject constructor(
    private val swapTransactionSummaryPreviewUseCase: SwapTransactionSummaryPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val swapQuote: SwapQuote = savedStateHandle.getOrThrow(SWAP_QUOTE_KEY)
    private val algorandTransactionFees: Long = savedStateHandle.getOrThrow(ALGORAND_TRANSACTION_FEES_KEY)
    private val optInTransactionFees: Long = savedStateHandle.getOrThrow(OPT_IN_TRANSACTION_FEES_KEY)

    private val _swapTransactionSummaryPreviewFlow = MutableStateFlow<SwapTransactionSummaryPreview?>(null)
    val swapTransactionSummaryPreviewFlow: StateFlow<SwapTransactionSummaryPreview?>
        get() = _swapTransactionSummaryPreviewFlow

    fun initSwapTransactionSummaryPreview(resources: Resources) {
        viewModelScope.launch {
            swapTransactionSummaryPreviewUseCase.getSwapSummaryPreview(
                resources,
                swapQuote,
                algorandTransactionFees,
                optInTransactionFees
            ).collectLatest { preview ->
                _swapTransactionSummaryPreviewFlow.emit(preview)
            }
        }
    }

    companion object {
        private const val SWAP_QUOTE_KEY = "swapQuote"
        private const val OPT_IN_TRANSACTION_FEES_KEY = "optInTransactionFees"
        private const val ALGORAND_TRANSACTION_FEES_KEY = "algorandTransactionFees"
    }
}
