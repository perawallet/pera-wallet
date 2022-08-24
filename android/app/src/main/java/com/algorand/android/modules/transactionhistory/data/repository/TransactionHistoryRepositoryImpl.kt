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
import com.algorand.android.utils.recordException
import javax.inject.Inject
import retrofit2.HttpException

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
        val safeAssetId = if (assetId == AssetInformation.ALGO_ID) null else assetId
        with(indexerApi.getTransactions(publicKey, safeAssetId, fromDate, toDate, nextToken, limit, txnType)) {
            return if (isSuccessful && body() != null) {
                body()?.let { Result.Success(paginatedTransactionsMapper.mapToPaginatedTransactionsDTO(it)) }
                    ?: Result.Error(HttpException(this))
            } else {
                recordException(HttpException(this))
                Result.Error(HttpException(this))
            }
        }
    }
}
