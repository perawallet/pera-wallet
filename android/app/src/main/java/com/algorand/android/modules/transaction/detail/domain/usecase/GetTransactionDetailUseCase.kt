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

package com.algorand.android.modules.transaction.detail.domain.usecase

import com.algorand.android.modules.transaction.common.domain.model.TransactionDTO
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.APP_TRANSACTION
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.ASSET_CONFIGURATION
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.ASSET_TRANSACTION
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.PAY_TRANSACTION
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.UNDEFINED
import com.algorand.android.modules.transaction.detail.domain.mapper.BaseTransactionDetailMapper
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.domain.repository.TransactionDetailRepository
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class GetTransactionDetailUseCase @Inject constructor(
    @Named(TransactionDetailRepository.TRANSACTION_DETAIL_REPOSITORY_INJECTION_NAME)
    private val transactionDetailRepository: TransactionDetailRepository,
    private val baseTransactionDetailMapper: BaseTransactionDetailMapper
) {

    suspend fun getTransactionDetail(transactionId: String) = flow<DataResource<BaseTransactionDetail>> {
        transactionDetailRepository.fetchTransactionDetail(transactionId).collect {
            it.use(
                onSuccess = { transactionDTO ->
                    val transactionDetail = mapTransactionDTOToTransactionDetail(transactionDTO)
                    emit(DataResource.Success(transactionDetail))
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api(exception, code))
                }
            )
        }
    }

    private fun mapTransactionDTOToTransactionDetail(transactionDTO: TransactionDTO): BaseTransactionDetail {
        return with(transactionDTO) {
            when (transactionType) {
                APP_TRANSACTION -> {
                    baseTransactionDetailMapper.mapToApplicationCallTransactionDetail(
                        transactionDTO = transactionDTO,
                        innerTransactions = innerTransactions?.map {
                            mapTransactionDTOToTransactionDetail(it)
                        }.orEmpty()
                    )
                }
                PAY_TRANSACTION -> baseTransactionDetailMapper.mapToPaymentTransactionDetail(this)
                ASSET_TRANSACTION -> baseTransactionDetailMapper.mapToAssetTransferTransactionDetail(this)
                ASSET_CONFIGURATION -> baseTransactionDetailMapper.mapToAssetConfigurationTransactionDetail(this)
                UNDEFINED -> baseTransactionDetailMapper.mapToUndefinedTransactionDetail(this)
                null -> baseTransactionDetailMapper.mapToUndefinedTransactionDetail(this)
            }
        }
    }
}
