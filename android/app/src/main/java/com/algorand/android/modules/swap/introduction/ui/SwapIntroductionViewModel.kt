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

package com.algorand.android.modules.swap.introduction.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.swap.introduction.ui.model.SwapIntroductionPreview
import com.algorand.android.modules.swap.introduction.ui.usecase.SwapIntroductionPreviewUseCase
import com.algorand.android.utils.getOrElse
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class SwapIntroductionViewModel @Inject constructor(
    private val swapIntroductionPreviewUseCase: SwapIntroductionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val accountAddress: String? = savedStateHandle.getOrElse(ACCOUNT_ADDRESS_KEY, null)
    private val fromAssetId = savedStateHandle.getOrElse(
        FROM_ASSET_ID_KEY,
        DEFAULT_ASSET_ID_ARG
    ).takeIf {
        it != DEFAULT_ASSET_ID_ARG
    }

    private val toAssetId = savedStateHandle.getOrElse(
        TO_ASSET_ID_KEY,
        DEFAULT_ASSET_ID_ARG
    ).takeIf {
        it != DEFAULT_ASSET_ID_ARG
    }

    private val _swapIntroductionPreviewFlow = MutableStateFlow<SwapIntroductionPreview?>(null)
    val swapIntroductionPreviewFlow: StateFlow<SwapIntroductionPreview?>
        get() = _swapIntroductionPreviewFlow

    fun onStartSwappingClick() {
        viewModelScope.launch {
            val newPreview = swapIntroductionPreviewUseCase.getSwapClickUpdatedPreview(
                accountAddress = accountAddress,
                fromAssetId = fromAssetId,
                toAssetId = toAssetId,
                defaultFromAssetIdArg = DEFAULT_ASSET_ID_ARG,
                defaultToAssetIdArg = DEFAULT_ASSET_ID_ARG
            )
            _swapIntroductionPreviewFlow.emit(newPreview)
        }
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        private const val FROM_ASSET_ID_KEY = "fromAssetId"
        private const val TO_ASSET_ID_KEY = "toAssetId"
        private const val DEFAULT_ASSET_ID_ARG = -1L
    }
}
