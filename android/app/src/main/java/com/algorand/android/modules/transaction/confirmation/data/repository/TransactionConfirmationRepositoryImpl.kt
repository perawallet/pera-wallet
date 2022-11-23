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

package com.algorand.android.modules.transaction.confirmation.data.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.algosdk.data.service.AlgorandSDKUtils
import com.algorand.android.modules.transaction.confirmation.data.mapper.TransactionConfirmationDTOMapper
import com.algorand.android.modules.transaction.confirmation.domain.model.TransactionConfirmationDTO
import com.algorand.android.modules.transaction.confirmation.domain.repository.TransactionConfirmationRepository
import com.algorand.android.utils.recordException
import javax.inject.Named
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class TransactionConfirmationRepositoryImpl(
    @Named(AlgorandSDKUtils.INJECTION_NAME)
    private val algorandSDKUtils: AlgorandSDKUtils,
    private val transactionConfirmationDTOMapper: TransactionConfirmationDTOMapper
) : TransactionConfirmationRepository {

    override suspend fun waitForConfirmation(
        txnId: String,
        maxRoundToWait: Int
    ): Result<TransactionConfirmationDTO> {
        return withContext(Dispatchers.IO) {
            try {
                val pendingTransactionResponseDTO = algorandSDKUtils.waitForConfirmation(txnId, maxRoundToWait)
                val transactionConfirmationResponseDTO = transactionConfirmationDTOMapper
                    .mapToTransactionConfirmationDto(pendingTransactionResponseDTO)
                Result.Success<TransactionConfirmationDTO>(transactionConfirmationResponseDTO)
            } catch (exception: Exception) {
                recordSdkException(exception)
                Result.Error(exception)
            }
        }
    }

    private fun recordSdkException(exception: Exception) {
        val tagUpdatedException = with(exception) {
            val updatedMessage = "$logTag $message"
            Exception(updatedMessage, cause)
        }
        recordException(tagUpdatedException)
    }

    companion object {
        private val logTag = TransactionConfirmationRepositoryImpl::class.java.simpleName
    }
}
