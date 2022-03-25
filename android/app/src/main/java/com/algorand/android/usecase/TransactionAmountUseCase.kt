/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.toAlgoDisplayValue
import java.math.BigDecimal
import java.math.BigDecimal.ZERO
import java.math.BigInteger
import javax.inject.Inject

// TODO Find a better name for this class
class TransactionAmountUseCase @Inject constructor(
    private val algoPriceUseCase: AlgoPriceUseCase
) : BaseUseCase() {

    fun getAlgoAmount(algoAmount: BigInteger?): BigDecimal {
        val algoPrice = algoPriceUseCase.getAlgoToSelectedCurrencyConversionRate() ?: ZERO
        val safeAlgoAmount = algoAmount ?: BigInteger.ZERO
        return safeAlgoAmount.toAlgoDisplayValue().multiply(algoPrice)
    }

    fun getAssetAmount(assetUsdValue: BigDecimal, amount: BigInteger?, decimal: Int?): BigDecimal {
        val selectedCurrencyUsdConversionRate = algoPriceUseCase.getUsdToSelectedCurrencyConversionRate()
        val safeDecimal = decimal ?: DEFAULT_ASSET_DECIMAL
        val safeAmount = amount ?: BigInteger.ZERO
        return safeAmount.toBigDecimal().movePointLeft(safeDecimal)
            .multiply(selectedCurrencyUsdConversionRate)
            .multiply(assetUsdValue)
    }
}
