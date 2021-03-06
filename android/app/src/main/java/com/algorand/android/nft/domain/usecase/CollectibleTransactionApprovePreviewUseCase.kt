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

import com.algorand.android.models.ui.CollectibleTransactionApprovePreview
import com.algorand.android.nft.mapper.CollectibleTransactionApprovePreviewMapper
import com.algorand.android.usecase.AccountNameIconUseCase
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsAlgoString
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class CollectibleTransactionApprovePreviewUseCase @Inject constructor(
    private val collectibleTransactionApprovePreviewMapper: CollectibleTransactionApprovePreviewMapper,
    private val accountNameIconUseCase: AccountNameIconUseCase
) {

    fun getCollectibleTransactionApprovePreviewFlow(
        senderPublicKey: String,
        receiverPublicKey: String,
        fee: Float
    ) = flow<CollectibleTransactionApprovePreview> {
        val (senderDisplayText, senderAccountIcon) = accountNameIconUseCase.getAccountDisplayTextAndIcon(
            senderPublicKey
        )
        val (receiverDisplayText, receiverAccountIcon) = accountNameIconUseCase.getAccountOrContactDisplayTextAndIcon(
            receiverPublicKey
        )
        val collectibleTransactionApprovePreview = collectibleTransactionApprovePreviewMapper.mapToPreview(
            senderAccountPublicKey = senderPublicKey,
            senderAccountDisplayText = senderDisplayText,
            senderAccountIcon = senderAccountIcon,
            receiverAccountPublicKey = receiverPublicKey,
            receiverAccountDisplayText = receiverDisplayText,
            receiverAccountIcon = receiverAccountIcon,
            formattedTransactionFee = fee.toLong().formatAsAlgoString().formatAsAlgoAmount()
        )
        emit(collectibleTransactionApprovePreview)
    }
}
