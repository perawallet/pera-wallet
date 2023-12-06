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
 */

package com.algorand.android.nft.ui.nftsend

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.nft.domain.usecase.CollectibleReceiverSelectionPreviewUseCase
import com.algorand.android.nft.ui.model.CollectibleReceiverSelectionPreview
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.launch

@HiltViewModel
class CollectibleReceiverSelectionViewModel @Inject constructor(
    private val collectibleReceiverSelectionPreviewUseCase: CollectibleReceiverSelectionPreviewUseCase
) : ViewModel() {

    private val _collectibleReceiverSelectionPreviewFlow = MutableStateFlow<CollectibleReceiverSelectionPreview?>(null)
    val collectibleReceiverSelectionPreviewFlow: StateFlow<CollectibleReceiverSelectionPreview?>
        get() = _collectibleReceiverSelectionPreviewFlow

    private val searchingQueryFlow = MutableStateFlow("")

    private val latestCopiedMessageFlow = MutableStateFlow<String?>(null)

    init {
        combineLatestCopiedMessageAndQueryFlow()
    }

    fun updateSearchingQuery(query: String) {
        viewModelScope.launch {
            searchingQueryFlow.emit(query)
        }
    }

    fun updateCopiedMessage(copiedMessage: String?) {
        viewModelScope.launch {
            latestCopiedMessageFlow.emit(copiedMessage)
        }
    }

    private fun combineLatestCopiedMessageAndQueryFlow() {
        viewModelScope.launch {
            combine(
                latestCopiedMessageFlow,
                searchingQueryFlow.debounce(QUERY_DEBOUNCE)
            ) { latestCopiedMessage, query ->
                collectibleReceiverSelectionPreviewUseCase.getCollectibleReceiverSelectionPreview(
                    query = query,
                    copiedMessage = latestCopiedMessage
                ).collectLatest {
                    _collectibleReceiverSelectionPreviewFlow.emit(it)
                }
            }.collect()
        }
    }

    companion object {
        private const val QUERY_DEBOUNCE = 400L
    }
}
