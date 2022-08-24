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

package com.algorand.android.modules.transaction.csv.data.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.transaction.csv.domain.repository.CsvRepository
import com.algorand.android.modules.transaction.csv.domain.repository.CsvRepository.Companion.MAX_TXN_REQUEST_COUNT
import com.algorand.android.modules.transaction.common.domain.model.TransactionDTO
import com.algorand.android.modules.transactionhistory.domain.repository.TransactionHistoryRepository
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.isActive
import kotlinx.coroutines.withContext

class CsvRepositoryImpl @Inject constructor(
    private val transactionHistoryRepository: TransactionHistoryRepository
) : CsvRepository {

    override suspend fun getCompleteTransactions(
        assetId: Long?,
        publicKey: String,
        fromDate: String?,
        toDate: String?,
        nextToken: String?,
        limit: Int?,
        txnType: String?
    ): Result<MutableList<TransactionDTO>> {
        return withContext(Dispatchers.IO) {
            var nextToken: String? = null
            var exception: Exception? = null
            var errorCode: Int? = null
            val transactionList = mutableListOf<TransactionDTO>()
            while (isActive) {
                transactionHistoryRepository.getTransactionHistory(
                    assetId,
                    publicKey,
                    fromDate,
                    toDate,
                    nextToken,
                    MAX_TXN_REQUEST_COUNT,
                    txnType
                ).use(
                    onSuccess = {
                        transactionList.addAll(it.transactionList)
                        nextToken = it.nextToken
                    }, onFailed = { excp, code ->
                        exception = excp
                        errorCode = code
                        nextToken = null
                    }
                )
                if (nextToken == null) break
            }
            if (transactionList.isEmpty() && exception != null) {
                Result.Error(exception!!, errorCode)
            } else {
                Result.Success(transactionList)
            }
        }
    }
}
