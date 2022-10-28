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

package com.algorand.android.nft.ui.receivenftasset

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import androidx.paging.cachedIn
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.assets.addition.base.ui.BaseAddAssetViewModel
import com.algorand.android.modules.assets.addition.base.ui.domain.BaseAddAssetPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch

@HiltViewModel
class ReceiveCollectibleViewModel @Inject constructor(
    private val receiveCollectiblePreviewUseCase: ReceiveCollectiblePreviewUseCase,
    baseAddAssetPreviewUseCase: BaseAddAssetPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseAddAssetViewModel(baseAddAssetPreviewUseCase) {

    private val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)

    private val queryTextFlow = MutableStateFlow("")

    override val searchPaginationFlow = receiveCollectiblePreviewUseCase.getSearchPaginationFlow(
        searchPagerBuilder = assetSearchPagerBuilder,
        scope = viewModelScope,
        queryText = queryTextFlow.value,
        accountAddress = accountAddress
    ).cachedIn(viewModelScope)

    init {
        initQueryTextFlow()
    }

    fun refreshReceiveCollectiblePreview() {
        receiveCollectiblePreviewUseCase.invalidateDataSource()
    }

    fun getReceiverAccountDisplayTextAndIcon(publicKey: String): Pair<String, AccountIconResource?> {
        return receiveCollectiblePreviewUseCase.getReceiverAccountDisplayTextAndIcon(publicKey)
    }

    fun updateQuery(query: String) {
        viewModelScope.launch {
            queryTextFlow.emit(query)
        }
    }

    private fun initQueryTextFlow() {
        queryTextFlow
            .onEach { receiveCollectiblePreviewUseCase.searchAsset(it) }
            .distinctUntilChanged()
            .launchIn(viewModelScope)
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
