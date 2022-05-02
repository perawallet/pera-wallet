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
import com.algorand.android.models.AssetTransaction
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.nft.ui.model.AssetSelectionPreview
import com.algorand.android.usecase.AssetSelectionUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class AssetSelectionViewModel @ViewModelInject constructor(
    private val assetSelectionUseCase: AssetSelectionUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    val assetTransaction = savedStateHandle.getOrThrow<AssetTransaction>(ASSET_TRANSACTION_KEY)

    val assetSelectionPreview: StateFlow<AssetSelectionPreview>
        get() = _assetSelectionPreview
    private val _assetSelectionPreview = MutableStateFlow(
        assetSelectionUseCase.getInitialStateOfAssetSelectionPreview(assetTransaction)
    )

    init {
        viewModelScope.launch(Dispatchers.IO) {
            assetSelectionUseCase.getAssetSelectionListFlow(assetTransaction.senderAddress).collectLatest { list ->
                _assetSelectionPreview.emit(
                    _assetSelectionPreview.value.copy(
                        assetList = list,
                        isLoadingVisible = false
                    )
                )
            }
        }
    }

    fun shouldShowTransactionTips(): Boolean {
        return assetSelectionUseCase.shouldShowTransactionTips()
    }

    fun isReceiverAccountSet(): Boolean {
        return assetTransaction.receiverUser != null
    }

    fun checkIfSelectedAccountReceiveAsset(assetId: Long) {
        viewModelScope.launch(Dispatchers.IO) {
            assetTransaction.receiverUser?.publicKey?.let {
                assetSelectionUseCase.checkIfSelectedAccountReceiveAsset(
                    it,
                    assetId,
                    _assetSelectionPreview.value
                ).collectLatest { assetSelectionPreview ->
                    _assetSelectionPreview.emit(assetSelectionPreview)
                }
            }
        }
    }

    fun getAssetOrCollectibleNameOrNull(assetId: Long): String? {
        return simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data?.fullName
            ?: simpleCollectibleUseCase.getCachedCollectibleById(assetId)?.data?.fullName
    }

    companion object {
        private const val ASSET_TRANSACTION_KEY = "assetTransaction"
    }
}
