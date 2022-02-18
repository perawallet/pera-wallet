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

package com.algorand.android.ui.send.transferpreview

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AssetTransferPreview
import com.algorand.android.models.Result
import com.algorand.android.models.SendTransactionResponse
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.usecase.AssetTransferPreviewUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class AssetTransferPreviewViewModel @ViewModelInject constructor(
    private val assetTransferPreviewUserCase: AssetTransferPreviewUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    private var sendAlgoJob: Job? = null
    private val signedTransactionDetail =
        savedStateHandle.getOrThrow<SignedTransactionDetail.Send>(SIGNED_TRANSACTION_DETAIL_KEY)

    private val _sendAlgoResponseFlow = MutableStateFlow<Event<Resource<SendTransactionResponse>>?>(null)
    val sendAlgoResponseFlow: StateFlow<Event<Resource<SendTransactionResponse>>?> = _sendAlgoResponseFlow

    private val _assetTransferPreviewFlow = MutableStateFlow<AssetTransferPreview?>(null)
    val assetTransferPreviewFlow: StateFlow<AssetTransferPreview?> = _assetTransferPreviewFlow

    init {
        getAssetTransferPreview()
    }

    private fun getAssetTransferPreview() {
        viewModelScope.launch {
            val signedTransactionPreview = assetTransferPreviewUserCase.getAssetTransferPreview(signedTransactionDetail)
            _assetTransferPreviewFlow.emit(signedTransactionPreview)
        }
    }

    fun sendSignedTransaction() {
        if (sendAlgoJob?.isActive == true) {
            return
        }
        sendAlgoJob = viewModelScope.launch {
            _sendAlgoResponseFlow.emit(Event(Resource.Loading))
            assetTransferPreviewUserCase.sendSignedTransaction(signedTransactionDetail).collectLatest {
                when (it) {
                    is Result.Error -> _sendAlgoResponseFlow.emit(Event(it.getAsResourceError()))
                    is Result.Success -> _sendAlgoResponseFlow.emit(Event(Resource.Success(it.data)))
                }
            }
        }
    }

    companion object {
        private const val SIGNED_TRANSACTION_DETAIL_KEY = "signedTransactionDetail"
    }
}
