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

package com.algorand.android.modules.transaction.confirmation.data.mapper

import com.algorand.android.modules.algosdk.data.model.PendingTransactionResponseDTO
import com.algorand.android.modules.transaction.confirmation.domain.model.TransactionConfirmationDTO
import javax.inject.Inject

class TransactionConfirmationDTOMapper @Inject constructor() {

    fun mapToTransactionConfirmationDto(
        response: PendingTransactionResponseDTO
    ): TransactionConfirmationDTO {
        return with(response) {
            TransactionConfirmationDTO(
                applicationIndex = applicationIndex,
                assetClosingAmount = assetClosingAmount,
                assetIndex = assetIndex,
                closeRewards = closeRewards,
                closingAmount = closingAmount,
                confirmedRound = confirmedRound,
                logs = logs,
                poolError = poolError,
                receiverRewards = receiverRewards,
                senderRewards = senderRewards,
            )
        }
    }
}
