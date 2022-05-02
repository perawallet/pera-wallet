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
import com.algorand.android.nft.domain.usecase.BaseCollectiblesListingPreviewUseCase
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

abstract class BaseCollectibleListingViewModel(
    private val baseCollectiblesPreviewUseCase: BaseCollectiblesListingPreviewUseCase
) : BaseViewModel() {

    protected abstract fun initCollectiblesListingPreviewFlow(searchKeyword: String): Flow<CollectiblesListingPreview>

    private var collectCollectibleListingPreviewJob: Job? = null

    private var searchKeyword = ""

    private val _collectiblesListingPreviewFlow = MutableStateFlow<CollectiblesListingPreview?>(null)
    val collectiblesListingPreviewFlow: Flow<CollectiblesListingPreview?>
        get() = _collectiblesListingPreviewFlow

    fun clearFilters() {
        baseCollectiblesPreviewUseCase.clearCollectibleFilters()
        startCollectibleListingPreviewFlow()
    }

    fun updateSearchKeyword(searchKeyword: String) {
        this.searchKeyword = searchKeyword
        startCollectibleListingPreviewFlow()
    }

    fun startCollectibleListingPreviewFlow() {
        if (collectCollectibleListingPreviewJob?.isActive == true) {
            collectCollectibleListingPreviewJob?.cancelChildren()
        }
        collectCollectibleListingPreviewJob = viewModelScope.launch {
            initCollectiblesListingPreviewFlow(searchKeyword).collectLatest {
                _collectiblesListingPreviewFlow.emit(it)
            }
        }
    }
}
