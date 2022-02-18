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
import com.algorand.android.models.CurrencyValue
import com.algorand.android.repository.PriceRepository
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class AlgoPriceUseCase @Inject constructor(
    private val currencyUseCase: CurrencyUseCase,
    private val priceRepository: PriceRepository
) : BaseUseCase() {

    fun getCachedAlgoPrice(selectedCurrency: String? = null): CacheResult<CurrencyValue>? {
        val currency = selectedCurrency ?: currencyUseCase.getSelectedCurrency()
        return priceRepository.getCachedAlgoPrice().takeIf { it?.data?.id == currency }
    }

    /**
     * Returns selected currency to usd conversion rate
     * Ex: USD-TRY -> 13.54
     */
    fun getConversionRateOfCachedCurrency(): BigDecimal {
        return priceRepository.getCachedAlgoPrice()?.data?.usdValue ?: BigDecimal.ZERO
    }

    fun getSelectedCurrencySymbol(): String {
        return priceRepository.getCachedAlgoPrice()?.data?.symbol ?: currencyUseCase.getSelectedCurrency()
    }

    fun cacheAlgoPrice(currencyValue: CacheResult<CurrencyValue>) {
        priceRepository.cacheAlgoPrice(currencyValue)
    }

    fun clearAlgoPriceCache() {
        priceRepository.clearAlgoPriceCache()
    }

    fun getAlgoPriceCacheFlow() = priceRepository.getAlgoPriceCacheFlow()

    fun fetchAlgoPrice() = flow {
        val selectedCurrency = currencyUseCase.getSelectedCurrency()
        priceRepository.getAlgorandCurrencyValue(selectedCurrency).use(
            onSuccess = {
                emit(DataResource.Success(it))
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api<CurrencyValue>(exception, code))
            }
        )
    }
}
