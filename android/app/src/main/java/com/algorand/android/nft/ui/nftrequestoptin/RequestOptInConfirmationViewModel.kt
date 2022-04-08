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

package com.algorand.android.nft.ui.nftrequestoptin

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.nft.domain.usecase.RequestOptInConfirmationPreviewUseCase
import com.algorand.android.nft.ui.model.RequestOptInConfirmationArgs
import com.algorand.android.nft.ui.model.RequestOptInConfirmationPreview
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class RequestOptInConfirmationViewModel @ViewModelInject constructor(
    private val requestOptInConfirmationPreviewUseCase: RequestOptInConfirmationPreviewUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val requestOptInConfirmationArgs =
        savedStateHandle.getOrThrow<RequestOptInConfirmationArgs>(REQUEST_OPT_IN_CONFIRMATION_ARGS_KEY)

    private val _requestOptInPreviewFlow = MutableStateFlow<RequestOptInConfirmationPreview>(
        requestOptInConfirmationPreviewUseCase.getInitialPreviewState(requestOptInConfirmationArgs.receiverPublicKey)
    )
    val requestOptInPreviewFlow: StateFlow<RequestOptInConfirmationPreview>
        get() = _requestOptInPreviewFlow

    fun sendOptInRequest() {
        viewModelScope.launch {
            with(requestOptInConfirmationArgs) {
                requestOptInConfirmationPreviewUseCase.sendOptInRequest(
                    collectibleId,
                    senderPublicKey,
                    _requestOptInPreviewFlow.value
                ).collect { preview ->
                    _requestOptInPreviewFlow.emit(preview)
                }
            }
        }
    }

    fun getCollectibleDisplayText(): String = with(requestOptInConfirmationArgs) {
        collectibleName ?: collectibleId.toString()
    }

    fun getReceiverPublicKey(): String = requestOptInConfirmationArgs.receiverPublicKey

    companion object {
        private const val REQUEST_OPT_IN_CONFIRMATION_ARGS_KEY = "requestOptInConfirmationArgs"
    }
}
