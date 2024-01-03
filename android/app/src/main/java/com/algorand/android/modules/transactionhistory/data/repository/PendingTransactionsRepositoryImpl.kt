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

package com.algorand.android.modules.transactionhistory.data.repository

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.modules.transactionhistory.data.mapper.PendingTransactionDTOMapper
import com.algorand.android.modules.transactionhistory.data.model.PendingTransactionsResponse
import com.algorand.android.modules.transactionhistory.domain.model.PendingTransactionDTO
import com.algorand.android.modules.transactionhistory.domain.repository.PendingTransactionsRepository
import com.algorand.android.network.AlgodApi
import com.algorand.android.network.safeApiCall
import javax.inject.Inject

class PendingTransactionsRepositoryImpl @Inject constructor(
    private val algodApi: AlgodApi,
    private val pendingTransactionMapper: PendingTransactionDTOMapper
) : PendingTransactionsRepository {
    override suspend fun getPendingTransactions(
        publicKey: String,
        assetId: Long?
    ): Result<List<PendingTransactionDTO>> {
        return safeApiCall { requestGetPendingTransactions(publicKey) }.map { pendingTransactionResponse ->
            val transactionItems = mutableListOf<PendingTransactionDTO>()

            pendingTransactionResponse.pendingTransactionResponses
                ?.filter {
                    if (assetId == null) {
                        true
                    } else {
                        val responseAssetId = it.detailResponse?.assetId ?: AssetInformation.ALGO_ID
                        responseAssetId == assetId
                    }
                }
                ?.ifEmpty { return@map emptyList<PendingTransactionDTO>() }
                ?.let {
                    transactionItems.addAll(it.map { pendingTransactionMapper.mapToTransactionDTO(it) })
                }
            transactionItems
        }
    }

    private suspend fun requestGetPendingTransactions(publicKey: String): Result<PendingTransactionsResponse> {
        with(algodApi.getPendingTransactions(publicKey)) {
            return if (isSuccessful && body() != null) {
                Result.Success(body() as PendingTransactionsResponse)
            } else {
                Result.Error(Exception(errorBody()?.charStream()?.readText()))
            }
        }
    }
}
