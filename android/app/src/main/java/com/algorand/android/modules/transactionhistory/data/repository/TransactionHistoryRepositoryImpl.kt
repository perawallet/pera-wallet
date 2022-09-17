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
import com.algorand.android.modules.transactionhistory.data.mapper.PaginatedTransactionsDTOMapper
import com.algorand.android.modules.transactionhistory.domain.model.PaginatedTransactionsDTO
import com.algorand.android.modules.transactionhistory.domain.repository.TransactionHistoryRepository
import com.algorand.android.network.IndexerApi
import com.algorand.android.network.request
import com.algorand.android.utils.recordException
import javax.inject.Inject

class TransactionHistoryRepositoryImpl @Inject constructor(
    private val indexerApi: IndexerApi,
    private val paginatedTransactionsMapper: PaginatedTransactionsDTOMapper
) : TransactionHistoryRepository {
    override suspend fun getTransactionHistory(
        assetId: Long?,
        publicKey: String,
        fromDate: String?,
        toDate: String?,
        nextToken: String?,
        limit: Int?,
        txnType: String?
    ): Result<PaginatedTransactionsDTO> {
        return request {
            val safeAssetId = if (assetId == AssetInformation.ALGO_ID) null else assetId
            indexerApi.getTransactions(
                publicKey = publicKey,
                assetId = safeAssetId,
                afterTime = fromDate,
                beforeTime = toDate,
                nextToken = nextToken,
                limit = limit,
                transactionType = txnType
            )
        }.run {
            when (this) {
                is Result.Success -> Result.Success(paginatedTransactionsMapper.mapToPaginatedTransactionsDTO(data))
                is Result.Error -> {
                    recordException(exception)
                    Result.Error(exception)
                }
            }
        }
    }
}
