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
import com.algorand.android.models.Currency
import com.algorand.android.models.CurrencyValue
import com.algorand.android.repository.PriceRepository
import com.algorand.android.repository.PriceRepository.Companion.CURRENCY_TO_CACHE_WHEN_ALGO_IS_SELECTED
import com.algorand.android.utils.ALGO_CURRENCY_SYMBOL
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import java.math.BigDecimal
import java.math.RoundingMode
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class AlgoPriceUseCase @Inject constructor(
    private val currencyUseCase: CurrencyUseCase,
    private val priceRepository: PriceRepository
) : BaseUseCase() {

    fun getCachedAlgoPrice(): CacheResult<CurrencyValue>? {
        return priceRepository.getCachedAlgoPrice().takeIf { it?.data?.id == getCachedCurrencyId() }
    }

    /**
     * Returns selected currency to usd conversion rate
     * Ex: USD-TRY -> 13.54
     * Currently, API does not support to fetch ALGO as a currency
     * That's why we make calculations based on the cached currency -> CURRENCY_TO_CACHE_WHEN_ALGO_IS_SELECTED
     */
    fun getUsdToSelectedCurrencyConversionRate(): BigDecimal {
        return if (currencyUseCase.getSelectedCurrency() == Currency.ALGO.id) {
            getUsdToAlgoConversionRate()
        } else {
            return priceRepository.getCachedAlgoPrice()?.data?.usdValue ?: BigDecimal.ZERO
        }
    }

    fun getAlgoToSelectedCurrencyConversionRate(): BigDecimal? {
        return if (currencyUseCase.getSelectedCurrency() == Currency.ALGO.id) {
            BigDecimal.ONE
        } else {
            getCachedAlgoPrice()?.data?.getAlgorandCurrencyValue()
        }
    }

    fun getAlgoToCachedCurrencyConversionRate(): BigDecimal? {
        return getCachedAlgoPrice()?.data?.getAlgorandCurrencyValue()
    }

    private fun getSelectedCurrencySymbol(): String? {
        val selectedCurrency = currencyUseCase.getSelectedCurrency()
        return if (selectedCurrency == Currency.ALGO.id) {
            ALGO_CURRENCY_SYMBOL
        } else {
            priceRepository.getCachedAlgoPrice()?.data?.symbol
        }
    }

    fun getSelectedCurrencySymbolOrEmpty(): String {
        return getSelectedCurrencySymbol() ?: ""
    }

    fun getSelectedCurrencySymbolOrCurrencyName(): String {
        return getSelectedCurrencySymbol() ?: currencyUseCase.getSelectedCurrency()
    }

    fun cacheAlgoPrice(currencyValue: CacheResult<CurrencyValue>) {
        priceRepository.cacheAlgoPrice(currencyValue)
    }

    fun clearAlgoPriceCache() {
        priceRepository.clearAlgoPriceCache()
    }

    fun getAlgoPriceCacheFlow() = priceRepository.getAlgoPriceCacheFlow()

    fun fetchAlgoPrice() = flow {
        priceRepository.getAlgorandCurrencyValue(getCachedCurrencyId()).use(
            onSuccess = {
                emit(DataResource.Success(it))
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api<CurrencyValue>(exception, code))
            }
        )
    }

    private fun getUsdToAlgoConversionRate(): BigDecimal {
        return priceRepository.getCachedAlgoPrice()?.data?.let {
            if (it.getAlgorandCurrencyValue() == BigDecimal.ZERO) {
                BigDecimal.ZERO
            } else {
                it.usdValue?.divide(
                    it.getAlgorandCurrencyValue() ?: return BigDecimal.ZERO,
                    ALGO_DECIMALS,
                    RoundingMode.HALF_UP
                )
            }
        } ?: BigDecimal.ZERO
    }

    fun getCachedCurrencyId(): String {
        return if (currencyUseCase.getSelectedCurrency() == Currency.ALGO.id) {
            CURRENCY_TO_CACHE_WHEN_ALGO_IS_SELECTED
        } else {
            currencyUseCase.getSelectedCurrency()
        }
    }
}
