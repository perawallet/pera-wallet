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

package com.algorand.android.nft.ui.base

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.tracking.nft.CollectibleEventTracker
import com.algorand.android.nft.domain.usecase.BaseCollectiblesListingPreviewUseCase
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.sharedpref.SharedPrefLocalSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

abstract class BaseCollectibleListingViewModel(
    private val baseCollectiblesPreviewUseCase: BaseCollectiblesListingPreviewUseCase,
    private val collectibleEventTracker: CollectibleEventTracker
) : BaseViewModel() {

    protected abstract suspend fun initCollectiblesListingPreviewFlow(
        searchKeyword: String
    ): Flow<CollectiblesListingPreview>

    protected abstract val nftListingViewTypeChangeListener: SharedPrefLocalSource.OnChangeListener<Int>

    private var collectCollectibleListingPreviewJob: Job? = null

    private val searchKeywordFlow = MutableStateFlow("")

    private val _collectiblesListingPreviewFlow = MutableStateFlow<CollectiblesListingPreview?>(null)
    val collectiblesListingPreviewFlow: StateFlow<CollectiblesListingPreview?> get() = _collectiblesListingPreviewFlow

    fun clearFilters() {
        viewModelScope.launch(Dispatchers.IO) {
            baseCollectiblesPreviewUseCase.clearCollectibleFilters()
            startCollectibleListingPreviewFlow()
        }
    }

    fun saveNFTListingViewTypePreference(nftListingViewType: NFTListingViewType) {
        viewModelScope.launch(Dispatchers.IO) {
            baseCollectiblesPreviewUseCase.saveNFTListingViewTypePreference(nftListingViewType)
        }
    }

    fun updateSearchKeyword(searchKeyword: String) {
        searchKeywordFlow.value = searchKeyword
    }

    fun logCollectibleReceiveEvent() {
        viewModelScope.launch(Dispatchers.IO) {
            collectibleEventTracker.logCollectibleReceiveEvent()
        }
    }

    fun startCollectibleListingPreviewFlow() {
        if (collectCollectibleListingPreviewJob?.isActive == true) {
            collectCollectibleListingPreviewJob?.cancel()
        }
        collectCollectibleListingPreviewJob = viewModelScope.launch(Dispatchers.IO) {
            searchKeywordFlow.debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .onStart { showLoadingState() }
                .flatMapLatest { searchKeyword -> initCollectiblesListingPreviewFlow(searchKeyword) }
                .collectLatest { preview -> _collectiblesListingPreviewFlow.emit(preview) }
        }
    }

    private fun showLoadingState() {
        _collectiblesListingPreviewFlow.update { it?.copy(isLoadingVisible = true) }
    }

    companion object {
        private const val QUERY_DEBOUNCE = 300L
    }
}
