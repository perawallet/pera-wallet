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

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.nft.domain.usecase.CollectibleReceiverSelectionPreviewUseCase
import com.algorand.android.nft.ui.model.CollectibleReceiverSelectionPreview
import com.algorand.android.utils.isValidAddress
import kotlin.properties.Delegates
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

class CollectibleReceiverSelectionViewModel @ViewModelInject constructor(
    private val collectibleReceiverSelectionPreviewUseCase: CollectibleReceiverSelectionPreviewUseCase
) : ViewModel() {

    private val _collectibleReceiverSelectionPreviewFlow = MutableStateFlow<CollectibleReceiverSelectionPreview?>(null)
    val collectibleReceiverSelectionPreviewFlow: StateFlow<CollectibleReceiverSelectionPreview?>
        get() = _collectibleReceiverSelectionPreviewFlow

    private val searchingQueryFlow = MutableStateFlow("")

    private var latestCopiedMessage: String? by Delegates.observable(null) { _, oldValue, newValue ->
        if (newValue != oldValue) {
            insertCopiedMessageToTopIfValid(newValue)
        }
    }

    init {
        initSearchingQueryFlow()
    }

    fun updateSearchingQuery(query: String) {
        viewModelScope.launch {
            searchingQueryFlow.emit(query)
        }
    }

    fun updateLatestCopiedMessage(message: String?) {
        latestCopiedMessage = message
    }

    private fun initSearchingQueryFlow() {
        viewModelScope.launch {
            searchingQueryFlow.debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { query ->
                    collectibleReceiverSelectionPreviewUseCase.getCollectibleReceiverSelectionPreview(query)
                }.collectLatest {
                    insertCopiedMessageToTopIfValid(latestCopiedMessage)
                    _collectibleReceiverSelectionPreviewFlow.emit(it)
                }
        }
    }

    private fun insertCopiedMessageToTopIfValid(copiedMessage: String?) {
        viewModelScope.launch {
            val copiedAddress = copiedMessage.takeIf { it.isValidAddress() } ?: return@launch
            _collectibleReceiverSelectionPreviewFlow.value?.accountSelectionItems
                ?.filter { it !is BaseAccountSelectionListItem.PasteItem }
                ?.toMutableList()
                ?.apply {
                    add(0, BaseAccountSelectionListItem.PasteItem(copiedAddress))
                    _collectibleReceiverSelectionPreviewFlow.emit(
                        _collectibleReceiverSelectionPreviewFlow.value?.copy(accountSelectionItems = this)
                    )
                }
        }
    }

    companion object {
        private const val QUERY_DEBOUNCE = 400L
    }
}
