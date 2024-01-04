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

package com.algorand.android.modules.assets.remove.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.assets.remove.ui.model.RemoveAssetsPreview
import com.algorand.android.modules.assets.remove.ui.usecase.RemoveAssetsPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

@HiltViewModel
class RemoveAssetsViewModel @Inject constructor(
    private val removeAssetsPreviewUseCase: RemoveAssetsPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val accountAddress = savedStateHandle.getOrThrow<String>(PUBLIC_KEY)

    private val _removeAssetsPreviewFlow = MutableStateFlow<RemoveAssetsPreview?>(null)
    val removeAssetsPreviewFlow: StateFlow<RemoveAssetsPreview?> = _removeAssetsPreviewFlow

    private val assetQueryFlow = MutableStateFlow("")

    init {
        initAssetQueryFlow()
    }

    fun updateSearchingQuery(query: String) {
        viewModelScope.launch { assetQueryFlow.emit(query) }
    }

    private fun initAssetQueryFlow() {
        viewModelScope.launch(Dispatchers.IO) {
            assetQueryFlow.debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { query -> removeAssetsPreviewUseCase.initRemoveAssetsPreview(accountAddress, query) }
                .collectLatest { _removeAssetsPreviewFlow.emit(it) }
        }
    }

    companion object {
        private const val PUBLIC_KEY = "publicKey"
        private const val QUERY_DEBOUNCE = 300L
    }
}
