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

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.CurrencyOption
import com.algorand.android.repository.PriceRepository
import com.algorand.android.repository.PriceRepository.Companion.CURRENCY_NOT_FOUND_ERROR_CODE
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class CurrencyOptionUseCase @Inject constructor(
    private val priceRepository: PriceRepository
) : BaseUseCase() {

    suspend fun getCurrencyOptionListFlow() = flow {
        emit(DataResource.Loading())
        priceRepository.getCurrencies().use(
            onSuccess = { currencyOptionList ->
                emit(DataResource.Success(currencyOptionList))
            },
            onFailed = { exception, code ->
                val dataResource = if (code == CURRENCY_NOT_FOUND_ERROR_CODE) {
                    DataResource.Success(listOf<CurrencyOption>())
                } else {
                    DataResource.Error.Api(exception, code)
                }
                emit(dataResource)
            }
        )
    }
}
