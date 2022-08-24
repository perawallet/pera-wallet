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

package com.algorand.android.modules.transactionhistory.data.mapper

import com.algorand.android.modules.transaction.common.data.mapper.TransactionTypeDTOMapper
import com.algorand.android.modules.transactionhistory.data.model.PendingTransactionDetailResponse
import com.algorand.android.modules.transactionhistory.domain.model.PendingTransactionDetailDTO
import javax.inject.Inject

class PendingTransactionDetailDTOMapper @Inject constructor(
    private val transactionTypeMapper: TransactionTypeDTOMapper
) {

    fun mapToTransactionDetailDTO(
        pendingTransactionDetailResponse: PendingTransactionDetailResponse
    ): PendingTransactionDetailDTO {
        pendingTransactionDetailResponse.let {
            return PendingTransactionDetailDTO(
                assetAmount = it.assetAmount,
                assetReceiverAddress = it.assetReceiverAddress,
                assetId = it.assetId,
                amount = it.amount,
                fee = it.fee,
                receiverAddress = it.receiverAddress,
                senderAddress = it.senderAddress,
                noteInBase64 = it.noteInBase64,
                transactionType = it.transactionType?.let { transactionTypeMapper.mapToTransactionTypeDTO(it) }
            )
        }
    }
}
