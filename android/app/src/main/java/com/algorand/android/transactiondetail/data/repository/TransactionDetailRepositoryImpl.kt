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

package com.algorand.android.transactiondetail.data.repository

import com.algorand.android.models.Result
import com.algorand.android.network.IndexerApi
import com.algorand.android.network.request
import com.algorand.android.transactiondetail.data.mapper.TransactionDetailDTOMapper
import com.algorand.android.transactiondetail.domain.model.TransactionDetailDTO
import com.algorand.android.transactiondetail.domain.repository.TransactionDetailRepository
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class TransactionDetailRepositoryImpl @Inject constructor(
    private val indexerApi: IndexerApi,
    private val transactionDetailDTOMapper: TransactionDetailDTOMapper
) : TransactionDetailRepository {
    override fun fetchTransactionDetail(transactionId: String): Flow<Result<TransactionDetailDTO>> = flow {
        request { indexerApi.getTransactionDetail(transactionId) }.use(
            onSuccess = {
                val transactionDetailDTO = transactionDetailDTOMapper.mapTo(it)
                emit(Result.Success(transactionDetailDTO))
            },
            onFailed = { exception, _ ->
                emit(Result.Error(exception))
            }
        )
    }
}
