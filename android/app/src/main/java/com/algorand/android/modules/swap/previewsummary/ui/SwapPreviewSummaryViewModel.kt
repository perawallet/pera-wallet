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

package com.algorand.android.modules.swap.previewsummary.ui

import android.content.res.Resources
import androidx.lifecycle.SavedStateHandle
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.previewsummary.ui.model.SwapPreviewSummaryPreview
import com.algorand.android.modules.swap.previewsummary.ui.usecase.SwapPreviewSummaryPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class SwapPreviewSummaryViewModel @Inject constructor(
    swapPreviewSummaryPreviewUseCase: SwapPreviewSummaryPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val swapQuote = savedStateHandle.getOrThrow<SwapQuote>(SWAP_QUOTE_KEY)

    private val _swapPreviewSummaryPreviewFlow = MutableStateFlow<SwapPreviewSummaryPreview>(
        swapPreviewSummaryPreviewUseCase.getInitialPreview(swapQuote)
    )
    val swapPreviewSummaryPreviewFlow: StateFlow<SwapPreviewSummaryPreview>
        get() = _swapPreviewSummaryPreviewFlow

    // TODO Move this logic into previewUseCase
    fun getUpdatedPriceRatio(resources: Resources): AnnotatedString {
        return _swapPreviewSummaryPreviewFlow.value.getSwitchedPriceRatio(resources)
    }

    companion object {
        private const val SWAP_QUOTE_KEY = "swapQuote"
    }
}
