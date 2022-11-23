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

package com.algorand.android.modules.parity.domain.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.modules.currency.domain.model.Currency
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.parity.domain.mapper.SelectedCurrencyDetailMapper
import com.algorand.android.modules.parity.domain.model.CurrencyDetailDTO
import com.algorand.android.modules.parity.domain.model.SelectedCurrencyDetail
import com.algorand.android.modules.parity.domain.repository.ParityRepository
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import java.math.BigDecimal
import java.math.RoundingMode
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.flow

class ParityUseCase @Inject constructor(
    private val currencyUseCase: CurrencyUseCase,
    @Named(ParityRepository.INJECTION_NAME)
    private val parityRepository: ParityRepository,
    private val selectedCurrencyDetailMapper: SelectedCurrencyDetailMapper
) : BaseUseCase() {

    fun getCachedSelectedCurrencyDetail(): CacheResult<SelectedCurrencyDetail>? {
        return parityRepository.getCachedSelectedCurrencyDetail()
    }

    fun cacheSelectedCurrencyDetail(selectedCurrencyDetail: CacheResult<SelectedCurrencyDetail>) {
        parityRepository.cacheSelectedCurrencyDetail(selectedCurrencyDetail)
    }

    fun clearSelectedCurrencyDetailCache() {
        parityRepository.clearSelectedCurrencyDetailCache()
    }

    fun getSelectedCurrencyDetailCacheFlow() = parityRepository.getSelectedCurrencyDetailCacheFlow()

    fun getUsdToAlgoConversionRate(): BigDecimal {
        return parityRepository.getCachedSelectedCurrencyDetail()?.data?.let {
            if (it.algoToSelectedCurrencyConversionRate == BigDecimal.ZERO ||
                it.algoToSelectedCurrencyConversionRate == null
            ) {
                BigDecimal.ZERO
            } else {
                it.usdToSelectedCurrencyConversionRate?.divide(
                    it.algoToSelectedCurrencyConversionRate,
                    SAFE_PARITY_DIVISION_DECIMALS,
                    RoundingMode.UP
                )
            }
        } ?: BigDecimal.ZERO
    }

    fun getAlgoToUsdConversionRate(): BigDecimal {
        return if (getUsdToAlgoConversionRate() != BigDecimal.ZERO) {
            BigDecimal.ONE.divide(getUsdToAlgoConversionRate(), SAFE_PARITY_DIVISION_DECIMALS, RoundingMode.UP)
        } else {
            BigDecimal.ZERO
        }
    }

    fun getUsdToPrimaryCurrencyConversionRate(): BigDecimal {
        return parityRepository.getCachedSelectedCurrencyDetail()?.data?.usdToSelectedCurrencyConversionRate
            ?: BigDecimal.ZERO
    }

    fun getAlgoToPrimaryCurrencyConversionRate(): BigDecimal {
        return parityRepository.getCachedSelectedCurrencyDetail()?.data?.algoToSelectedCurrencyConversionRate
            ?: BigDecimal.ZERO
    }

    fun getUsdToSecondaryCurrencyConversionRate(): BigDecimal {
        return if (currencyUseCase.isPrimaryCurrencyAlgo()) {
            BigDecimal.ONE
        } else {
            getUsdToAlgoConversionRate()
        }
    }

    fun getAlgoToSecondaryCurrencyConversionRate(): BigDecimal {
        return if (currencyUseCase.isPrimaryCurrencyAlgo()) {
            getAlgoToUsdConversionRate()
        } else {
            BigDecimal.ONE
        }
    }

    private fun getPrimaryCurrencySymbol(): String? {
        return parityRepository.getCachedSelectedCurrencyDetail()?.data?.currencySymbol
    }

    fun getPrimaryCurrencySymbolOrName(): String {
        return getPrimaryCurrencySymbol() ?: currencyUseCase.getPrimaryCurrencyId()
    }

    fun getPrimaryCurrencySymbolOrEmpty(): String {
        return parityRepository.getCachedSelectedCurrencyDetail()?.data?.currencySymbol.orEmpty()
    }

    fun getSecondaryCurrencySymbol(): String {
        return if (currencyUseCase.isPrimaryCurrencyAlgo()) Currency.USD.symbol else Currency.ALGO.symbol
    }

    /**
     * When we display currency, if ALGO is primary currency we use secondary currency ratio and symbol
     * If primary currency is not ALGO, then we use primary currency ratio and symbol
     */
    fun getDisplayedCurrencyRatio(): BigDecimal {
        return if (currencyUseCase.isPrimaryCurrencyAlgo()) {
            getUsdToSecondaryCurrencyConversionRate()
        } else {
            getUsdToPrimaryCurrencyConversionRate()
        }
    }

    /**
     * When we display currency, if ALGO is primary currency we use secondary currency ratio and symbol
     * If primary currency is not ALGO, then we use primary currency ratio and symbol
     */
    fun getDisplayedCurrencySymbol(): String {
        return if (currencyUseCase.isPrimaryCurrencyAlgo()) {
            getSecondaryCurrencySymbol()
        } else {
            getPrimaryCurrencySymbolOrName()
        }
    }

    private fun getCurrencyToFetch(): String {
        return if (currencyUseCase.isPrimaryCurrencyAlgo()) {
            CURRENCY_TO_FETCH_WHEN_ALGO_IS_SELECTED
        } else {
            currencyUseCase.getPrimaryCurrencyId()
        }
    }

    fun fetchSelectedCurrencyDetail() = flow {
        parityRepository.fetchCurrencyDetailDTO(getCurrencyToFetch()).use(
            onSuccess = { currencyDetailDTO ->
                val isPrimaryCurrencyAlgo = currencyUseCase.isPrimaryCurrencyAlgo()
                emit(
                    DataResource.Success(
                        selectedCurrencyDetailMapper.mapToSelectedCurrencyDetail(
                            getSelectedCurrencyId(currencyDetailDTO, isPrimaryCurrencyAlgo),
                            getSelectedCurrencyName(currencyDetailDTO, isPrimaryCurrencyAlgo),
                            getSelectedCurrencySymbol(currencyDetailDTO, isPrimaryCurrencyAlgo),
                            getAlgoToSelectedCurrencyParityValue(currencyDetailDTO, isPrimaryCurrencyAlgo),
                            getUsdToSelectedCurrencyParityValue(currencyDetailDTO, isPrimaryCurrencyAlgo)
                        )
                    )
                )
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api<SelectedCurrencyDetail>(exception, code))
            }
        )
    }

    private fun getSelectedCurrencyId(
        currencyDetailDTO: CurrencyDetailDTO,
        isSelectedCurrencyAlgo: Boolean
    ): String {
        return if (isSelectedCurrencyAlgo) Currency.ALGO.id else currencyDetailDTO.id
    }

    private fun getSelectedCurrencyName(
        currencyDetailDTO: CurrencyDetailDTO,
        isSelectedCurrencyAlgo: Boolean
    ): String? {
        return if (isSelectedCurrencyAlgo) Currency.ALGO.id else currencyDetailDTO.name
    }

    private fun getSelectedCurrencySymbol(
        currencyDetailDTO: CurrencyDetailDTO,
        isSelectedCurrencyAlgo: Boolean
    ): String? {
        return if (isSelectedCurrencyAlgo) Currency.ALGO.symbol else currencyDetailDTO.symbol
    }

    private fun getAlgoToSelectedCurrencyParityValue(
        currencyDetailDTO: CurrencyDetailDTO,
        isSelectedCurrencyAlgo: Boolean
    ): BigDecimal? {
        return if (isSelectedCurrencyAlgo) {
            BigDecimal.ONE
        } else {
            currencyDetailDTO.exchangePrice?.toBigDecimalOrNull()
        }
    }

    private fun getUsdToSelectedCurrencyParityValue(
        currencyDetailDTO: CurrencyDetailDTO,
        isSelectedCurrencyAlgo: Boolean
    ): BigDecimal? {
        with(currencyDetailDTO) {
            return if (isSelectedCurrencyAlgo) {
                val algoToCurrencyConversionRate = exchangePrice?.toBigDecimalOrNull()
                if (algoToCurrencyConversionRate == BigDecimal.ZERO || algoToCurrencyConversionRate == null) {
                    BigDecimal.ZERO
                } else {
                    usdValue?.divide(algoToCurrencyConversionRate, SAFE_PARITY_DIVISION_DECIMALS, RoundingMode.UP)
                }
            } else {
                currencyDetailDTO.usdValue
            }
        }
    }

    companion object {
        private val CURRENCY_TO_FETCH_WHEN_ALGO_IS_SELECTED = Currency.USD.id

        // ALGO is not returned as a currency from API so all calculations are done locally when ALGO is selected
        // SAFE_PARITY_DIVISION_DECIMALS constant is ONLY used in ALGO/USD, USD/ALGO conversion calculations
        // The bigger the constant is, the more accurate we are calculating the conversion rate
        // Currently it is set to 10 which means results will accurate only until 10th decimal
        // This is acceptable for now, because we do not show after 6th decimals in the UI
        private const val SAFE_PARITY_DIVISION_DECIMALS = 10
    }
}
