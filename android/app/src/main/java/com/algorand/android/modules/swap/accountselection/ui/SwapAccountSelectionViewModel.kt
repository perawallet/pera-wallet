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

package com.algorand.android.modules.swap.accountselection.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.swap.accountselection.ui.model.SwapAccountSelectionPreview
import com.algorand.android.modules.swap.accountselection.ui.usecase.SwapAccountSelectionPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class SwapAccountSelectionViewModel @Inject constructor(
    private val swapAccountSelectionPreviewUseCase: SwapAccountSelectionPreviewUseCase
) : BaseViewModel() {

    private val _swapAccountSelectionPreviewFlow = MutableStateFlow<SwapAccountSelectionPreview>(
        swapAccountSelectionPreviewUseCase.getSwapAccountSelectionInitialPreview()
    )
    val swapAccountSelectionPreviewFlow: StateFlow<SwapAccountSelectionPreview> get() = _swapAccountSelectionPreviewFlow

    init {
        initSwapAccountSelectionPreviewFlow()
    }

    fun onAccountSelected(accountAddress: String) {
        viewModelScope.launch {
            val newState = swapAccountSelectionPreviewUseCase.getAccountSelectedUpdatedPreview(
                accountAddress = accountAddress,
                previousState = _swapAccountSelectionPreviewFlow.value
            )
            _swapAccountSelectionPreviewFlow.emit(newState)
        }
    }

    private fun initSwapAccountSelectionPreviewFlow() {
        viewModelScope.launch {
            val swapAccountSelectionPreview = swapAccountSelectionPreviewUseCase.getSwapAccountSelectionPreview()
            _swapAccountSelectionPreviewFlow.emit(swapAccountSelectionPreview)
        }
    }
}
