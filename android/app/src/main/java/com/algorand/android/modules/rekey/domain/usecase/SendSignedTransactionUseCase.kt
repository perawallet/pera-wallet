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

package com.algorand.android.modules.rekey.domain.usecase

import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.DataResource
import javax.inject.Inject

class SendSignedTransactionUseCase @Inject constructor(
    private val transactionsRepository: TransactionsRepository
) {

    suspend operator fun invoke(transactionDetail: SignedTransactionDetail): DataResource<Unit> {
        lateinit var dataResource: DataResource<Unit>
        transactionsRepository.sendSignedTransaction(transactionDetail.signedTransactionData).use(
            onSuccess = {
                dataResource = DataResource.Success(Unit)
            },
            onFailed = { exception, code ->
                dataResource = DataResource.Error.Api(exception, code)
            }
        )
        return dataResource
    }
}
