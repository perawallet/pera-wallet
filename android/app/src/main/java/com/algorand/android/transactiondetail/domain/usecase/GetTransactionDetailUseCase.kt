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

package com.algorand.android.transactiondetail.domain.usecase

import com.algorand.android.transactiondetail.domain.model.TransactionDetail
import com.algorand.android.transactiondetail.domain.repository.TransactionDetailRepository
import com.algorand.android.transactiondetail.domain.mapper.TransactionDetailMapper
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class GetTransactionDetailUseCase @Inject constructor(
    @Named(TransactionDetailRepository.TRANSACTION_DETAIL_REPOSITORY_INJECTION_NAME)
    private val transactionDetailRepository: TransactionDetailRepository,
    private val transactionDetailMapper: TransactionDetailMapper
) {

    suspend fun getTransactionDetail(transactionId: String) = flow<DataResource<TransactionDetail>> {
        transactionDetailRepository.fetchTransactionDetail(transactionId).collect {
            it.use(
                onSuccess = { transactionDetailDTO ->
                    val transactionDetail = transactionDetailMapper.mapTo(transactionDetailDTO)
                    emit(DataResource.Success(transactionDetail))
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api(exception, code))
                }
            )
        }
    }
}
