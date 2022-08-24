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

package com.algorand.android.modules.transactionhistory.domain.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.transactionhistory.domain.model.PaginatedTransactionsDTO
import com.algorand.android.repository.TransactionsRepository

interface TransactionHistoryRepository {

    suspend fun getTransactionHistory(
        assetId: Long? = null,
        publicKey: String,
        fromDate: String? = null,
        toDate: String? = null,
        nextToken: String? = null,
        limit: Int? = TransactionsRepository.DEFAULT_TRANSACTION_COUNT,
        txnType: String? = null
    ): Result<PaginatedTransactionsDTO>

    companion object {
        const val INJECTION_NAME = "transactionHistoryRepositoryInjectionName"
    }
}
