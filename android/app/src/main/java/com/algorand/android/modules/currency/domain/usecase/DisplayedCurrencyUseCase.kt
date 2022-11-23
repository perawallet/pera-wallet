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

package com.algorand.android.modules.currency.domain.usecase

import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.parity.domain.usecase.PrimaryCurrencyParityCalculationUseCase
import com.algorand.android.modules.parity.domain.usecase.SecondaryCurrencyParityCalculationUseCase
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

/**
 * This class is meant to be used to get "displayed currency"
 * Which means; when there is only single place to show currency, we show based on logic below;
 * if primary currency is Algo -> show USD
 * else -> show selected currency
 */
class DisplayedCurrencyUseCase @Inject constructor(
    private val currencyUseCase: CurrencyUseCase,
    private val primaryCurrencyParityCalculationUseCase: PrimaryCurrencyParityCalculationUseCase,
    private val secondaryCurrencyParityCalculationUseCase: SecondaryCurrencyParityCalculationUseCase,
    private val parityUseCase: ParityUseCase
) {

    fun getDisplayedCurrencySymbol(): String = parityUseCase.getDisplayedCurrencySymbol()

    fun getDisplayedCurrencyParityValue(
        assetAmount: BigInteger,
        assetUsdValue: BigDecimal,
        assetDecimal: Int
    ): ParityValue {
        return if (currencyUseCase.isPrimaryCurrencyAlgo()) {
            secondaryCurrencyParityCalculationUseCase.getAssetParityValue(assetAmount, assetUsdValue, assetDecimal)
        } else {
            primaryCurrencyParityCalculationUseCase.getAssetParityValue(assetAmount, assetUsdValue, assetDecimal)
        }
    }
}
