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

package com.algorand.android.nft.ui.nfsdetail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.nft.domain.usecase.CollectibleDetailPreviewUseCase
import com.algorand.android.nft.ui.model.CollectibleDetailPreview
import com.algorand.android.nft.ui.nfsdetail.base.BaseCollectibleDetailViewModel
import com.algorand.android.usecase.NetworkSlugUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class CollectibleDetailViewModel @Inject constructor(
    private val collectibleDetailPreviewUseCase: CollectibleDetailPreviewUseCase,
    networkSlugUseCase: NetworkSlugUseCase,
    savedStateHandle: SavedStateHandle
) : BaseCollectibleDetailViewModel(networkSlugUseCase) {

    private val collectibleAssetId = savedStateHandle.getOrThrow<Long>(COLLECTIBLE_ASSET_ID_KEY)
    private val selectedAccountPublicKey = savedStateHandle.getOrThrow<String>(PUBLIC_KEY_KEY)

    private val _collectibleDetailPreviewFlow = MutableStateFlow<CollectibleDetailPreview?>(null)
    val collectibleDetailFlow: StateFlow<CollectibleDetailPreview?>
        get() = _collectibleDetailPreviewFlow

    init {
        getCollectibleDetailPreview()
    }

    fun checkSendingCollectibleIsFractional() {
        viewModelScope.launch(Dispatchers.IO) {
            collectibleDetailPreviewUseCase.checkSendingCollectibleIsFractional(collectibleDetailFlow.value).collect {
                _collectibleDetailPreviewFlow.emit(it)
            }
        }
    }

    private fun getCollectibleDetailPreview() {
        viewModelScope.launch {
            collectibleDetailPreviewUseCase
                .getCollectableDetailPreviewFlow(collectibleAssetId, selectedAccountPublicKey)
                .collectLatest { _collectibleDetailPreviewFlow.emit(it) }
        }
    }

    companion object {
        private const val COLLECTIBLE_ASSET_ID_KEY = "collectibleAssetId"
        private const val PUBLIC_KEY_KEY = "publicKey"
    }
}
