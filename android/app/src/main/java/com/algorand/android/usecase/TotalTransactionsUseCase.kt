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

package com.algorand.android.usecase

import com.algorand.android.models.Result
import com.algorand.android.models.Transaction
import com.algorand.android.repository.TransactionsRepository
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.isActive
import kotlinx.coroutines.withContext

class TotalTransactionsUseCase @Inject constructor(
    private val transactionsRepository: TransactionsRepository
) {
    suspend fun getCompleteTransactions(
        assetId: Long? = null,
        publicKey: String,
        fromDate: String? = null,
        toDate: String? = null,
        txnType: String? = null
    ): Result<MutableList<Transaction>> {
        return withContext(Dispatchers.IO) {
            var nextToken: String? = null
            var exception: Exception? = null
            var errorCode: Int? = null
            val transactionList = mutableListOf<Transaction>()
            while (isActive) {
                transactionsRepository.getTransactionHistory(
                    assetId, publicKey, fromDate, toDate, nextToken, MAX_TXN_REQUEST_COUNT, txnType
                )
                    .use(
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

    companion object {
        private const val MAX_TXN_REQUEST_COUNT = 1000
    }
}
