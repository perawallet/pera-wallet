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

package com.algorand.android.nft.ui.nftapprovetransaction

import javax.inject.Inject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.ui.CollectibleTransactionApprovePreview
import com.algorand.android.nft.domain.usecase.CollectibleTransactionApprovePreviewUseCase
import com.algorand.android.nft.ui.model.CollectibleDetail
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

@HiltViewModel
class CollectibleTransactionApproveViewModel @Inject constructor(
    private val collectibleTransactionApprovePreviewUseCase: CollectibleTransactionApprovePreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val senderPublicKey = savedStateHandle.getOrThrow<String>(SENDER_PUBLIC_KEY_KEY)
    private val receiverPublicKey = savedStateHandle.getOrThrow<String>(RECEIVER_PUBLIC_KEY_KEY)
    private val fee = savedStateHandle.getOrThrow<Float>(FEE_KEY)
    private val collectibleDetail = savedStateHandle.getOrThrow<CollectibleDetail>(COLLECTIBLE_DETAIL_KEY)

    val collectibleTransactionApprovePreviewFlow: Flow<CollectibleTransactionApprovePreview?>
        get() = _collectibleTransactionApprovePreviewFlow
    private val _collectibleTransactionApprovePreviewFlow =
        MutableStateFlow<CollectibleTransactionApprovePreview?>(null)

    init {
        initCollectibleTransactionApprovePreviewFlow()
    }

    private fun initCollectibleTransactionApprovePreviewFlow() {
        viewModelScope.launch {
            collectibleTransactionApprovePreviewUseCase.getCollectibleTransactionApprovePreviewFlow(
                senderPublicKey = senderPublicKey,
                receiverPublicKey = receiverPublicKey,
                fee = fee,
                collectibleDetail = collectibleDetail
            ).collect { _collectibleTransactionApprovePreviewFlow.emit(it) }
        }
    }

    companion object {
        private const val SENDER_PUBLIC_KEY_KEY = "senderPublicKey"
        private const val RECEIVER_PUBLIC_KEY_KEY = "receiverPublicKey"
        private const val FEE_KEY = "fee"
        private const val COLLECTIBLE_DETAIL_KEY = "collectibleDetail"
    }
}
