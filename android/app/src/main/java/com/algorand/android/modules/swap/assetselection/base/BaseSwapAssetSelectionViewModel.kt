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

package com.algorand.android.modules.swap.assetselection.base

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapAssetSelectionPreview
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

abstract class BaseSwapAssetSelectionViewModel : BaseViewModel() {

    private val searchQueryFlow = MutableStateFlow<String?>(null)
    protected val searchQuery: String?
        get() = searchQueryFlow.value

    private val _swapAssetSelectionPreviewFlow = MutableStateFlow<SwapAssetSelectionPreview?>(null)
    val swapAssetSelectionPreviewFlow: StateFlow<SwapAssetSelectionPreview?>
        get() = _swapAssetSelectionPreviewFlow

    abstract suspend fun onQueryChanged(query: String?): Flow<SwapAssetSelectionPreview>

    init {
        initSearchQueryFlow()
    }

    fun updateSearchQuery(query: String) {
        searchQueryFlow.value = query
    }

    private fun initSearchQueryFlow() {
        viewModelScope.launch {
            searchQueryFlow
                .debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { query ->
                    onQueryChanged(query)
                }.collectLatest { swapAssetSelectionPreview ->
                    _swapAssetSelectionPreviewFlow.emit(swapAssetSelectionPreview)
                }
        }
    }

    protected fun updatePreview(preview: SwapAssetSelectionPreview) {
        _swapAssetSelectionPreviewFlow.value = preview
    }

    companion object {
        private const val QUERY_DEBOUNCE = 400L
    }
}
