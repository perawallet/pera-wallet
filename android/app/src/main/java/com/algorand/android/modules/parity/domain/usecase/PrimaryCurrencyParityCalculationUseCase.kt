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

import com.algorand.android.models.AssetHolding
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.modules.parity.domain.mapper.ParityValueMapper
import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.utils.ALGO_DECIMALS
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

/**
Primary currency is always selected currency
So we convert every value into usd and from usd to selected currency
 */
class PrimaryCurrencyParityCalculationUseCase @Inject constructor(
    private val parityUseCase: ParityUseCase,
    parityValueMapper: ParityValueMapper
) : BaseParityCalculationUseCase(parityValueMapper) {

    override fun getAssetParityValue(assetHolding: AssetHolding, assetItem: BaseAssetDetail): ParityValue {
        val usdToSelectedCurrencyConversionRate = parityUseCase.getUsdToPrimaryCurrencyConversionRate()
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrEmpty()
        return calculateParityValue(
            assetUsdValue = assetItem.usdValue,
            assetDecimals = assetItem.fractionDecimals,
            amount = assetHolding.amount,
            conversionRate = usdToSelectedCurrencyConversionRate,
            currencySymbol = selectedCurrencySymbol
        )
    }

    override fun getAssetParityValue(
        assetAmount: BigInteger,
        assetUsdValue: BigDecimal,
        assetDecimal: Int
    ): ParityValue {
        val usdToSelectedCurrencyConversionRate = parityUseCase.getUsdToPrimaryCurrencyConversionRate()
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrEmpty()
        return calculateParityValue(
            assetUsdValue = assetUsdValue,
            assetDecimals = assetDecimal,
            amount = assetAmount,
            conversionRate = usdToSelectedCurrencyConversionRate,
            currencySymbol = selectedCurrencySymbol
        )
    }

    override fun getAlgoParityValue(algoAmount: BigInteger): ParityValue {
        val algoToUsdConversionRate = parityUseCase.getAlgoToUsdConversionRate()
        val usdToSelectedCurrencyConversionRate = parityUseCase.getUsdToPrimaryCurrencyConversionRate()
        val symbol = parityUseCase.getPrimaryCurrencySymbolOrEmpty()
        return calculateParityValue(
            assetUsdValue = algoToUsdConversionRate,
            assetDecimals = ALGO_DECIMALS,
            amount = algoAmount,
            conversionRate = usdToSelectedCurrencyConversionRate,
            currencySymbol = symbol
        )
    }
}
