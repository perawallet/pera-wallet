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

package com.algorand.android.modules.transaction.confirmation.domain.usecase

import com.algorand.android.modules.transaction.confirmation.domain.mapper.TransactionConfirmationMapper
import com.algorand.android.modules.transaction.confirmation.domain.model.TransactionConfirmation
import com.algorand.android.modules.transaction.confirmation.domain.repository.TransactionConfirmationRepository
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.flow

class TransactionConfirmationUseCase @Inject constructor(
    @Named(TransactionConfirmationRepository.INJECTION_NAME)
    private val transactionConfirmationRepository: TransactionConfirmationRepository,
    private val transactionConfirmationMapper: TransactionConfirmationMapper
) {

    suspend fun waitForConfirmation(
        txnId: String,
        maxRoundToWait: Int = DEFAULT_MAX_ROUND_TO_WAIT
    ) = flow<DataResource<TransactionConfirmation>> {
        transactionConfirmationRepository.waitForConfirmation(txnId, maxRoundToWait).use(
            onSuccess = { dto ->
                val transactionConfirmation = transactionConfirmationMapper.mapToTransactionConfirmation(dto)
                emit(DataResource.Success(transactionConfirmation))
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api(exception, code))
            }
        )
    }

    companion object {
        private const val DEFAULT_MAX_ROUND_TO_WAIT = 3
    }
}
