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

package com.algorand.android.modules.swap.assetselection.fromasset.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.modules.swap.assetselection.base.BaseSwapAssetSelectionViewModel
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapAssetSelectionPreview
import com.algorand.android.modules.swap.assetselection.fromasset.ui.usecase.SwapFromAssetSelectionPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow

@HiltViewModel
class SwapFromAssetSelectionViewModel @Inject constructor(
    private val swapFromAssetSelectionPreviewUseCase: SwapFromAssetSelectionPreviewUseCase,
    private val savedStateHandle: SavedStateHandle
) : BaseSwapAssetSelectionViewModel() {

    private val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)

    override suspend fun onQueryChanged(query: String?): Flow<SwapAssetSelectionPreview> {
        return swapFromAssetSelectionPreviewUseCase.getSwapAssetSelectionPreview(accountAddress, query)
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
