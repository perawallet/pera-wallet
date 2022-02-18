/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.send.assetselection

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AssetSelection
import com.algorand.android.models.AssetTransaction
import com.algorand.android.usecase.AssetSelectionUseCase
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AssetSelectionViewModel @ViewModelInject constructor(
    private val assetSelectionUseCase: AssetSelectionUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    val assetTransaction = savedStateHandle.getOrThrow<AssetTransaction>(ASSET_TRANSACTION_KEY)

    private val _assetSelectionFlow = MutableStateFlow<List<AssetSelection>?>(null)
    val assetSelectionFlow: StateFlow<List<AssetSelection>?> = _assetSelectionFlow

    init {
        getAssets()
    }

    private fun getAssets() {
        viewModelScope.launch {
            _assetSelectionFlow.emit(assetSelectionUseCase.getAssets(assetTransaction.senderAddress))
        }
    }

    fun shouldShowTransactionTips(): Boolean {
        return assetSelectionUseCase.shouldShowTransactionTips()
    }

    companion object {
        private const val ASSET_TRANSACTION_KEY = "assetTransaction"
    }
}
