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

package com.algorand.android.nft.domain.usecase

import com.algorand.android.nft.mapper.RequestOptInConfirmationMapper
import com.algorand.android.nft.ui.model.RequestOptInConfirmationPreview
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class RequestOptInConfirmationPreviewUseCase @Inject constructor(
    private val requestOptInConfirmationMapper: RequestOptInConfirmationMapper,
    private val sendAssetOptInRequestUseCase: SendAssetOptInRequestUseCase
) {

    fun getInitialPreviewState(receiverPublicKey: String): RequestOptInConfirmationPreview {
        return requestOptInConfirmationMapper.mapToInitialState(receiverPublicKey)
    }

    fun sendOptInRequest(
        collectibleId: Long,
        senderPublicKey: String,
        previousState: RequestOptInConfirmationPreview
    ) = flow {
        emit(previousState.copy(isLoadingVisible = true))
        with(previousState) {
            sendAssetOptInRequestUseCase.sendAssetOptInRequest(
                senderPublicKey,
                receiverPublicKey,
                collectibleId
            ).collect {
                when (it) {
                    is DataResource.Success -> emit(getSuccessStateOfOptInRequest(previousState))
                    is DataResource.Error -> emit(getErrorStateOfOptInRequest(previousState, it.exception))
                }
            }
        }
    }

    private fun getSuccessStateOfOptInRequest(
        previewState: RequestOptInConfirmationPreview
    ): RequestOptInConfirmationPreview {
        return previewState.copy(
            isLoadingVisible = false,
            requestSendSuccessEvent = Event(Unit)
        )
    }

    private fun getErrorStateOfOptInRequest(
        previewState: RequestOptInConfirmationPreview,
        exception: Throwable?
    ): RequestOptInConfirmationPreview {
        return previewState.copy(
            isLoadingVisible = false,
            globalErrorEvent = if (exception?.message.isNullOrBlank()) null else Event(exception?.message.orEmpty())
        )
    }
}
