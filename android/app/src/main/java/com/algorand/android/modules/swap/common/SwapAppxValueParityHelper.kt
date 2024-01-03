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

package com.algorand.android.modules.swap.common

import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.parity.domain.usecase.PrimaryCurrencyParityCalculationUseCase
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class SwapAppxValueParityHelper @Inject constructor(
    private val primaryCurrencyParityCalculationUseCase: PrimaryCurrencyParityCalculationUseCase,
    private val parityUseCase: ParityUseCase
) {

    fun getDisplayedCurrencySymbol(): String = parityUseCase.getPrimaryCurrencySymbolOrName()

    fun getDisplayedParityCurrencyValue(
        assetAmount: BigInteger,
        assetUsdValue: BigDecimal,
        assetDecimal: Int,
        assetId: Long
    ): ParityValue {
        return if (assetId == ALGO_ID) {
            primaryCurrencyParityCalculationUseCase.getAlgoParityValue(assetAmount)
        } else {
            primaryCurrencyParityCalculationUseCase.getAssetParityValue(
                assetAmount = assetAmount,
                assetUsdValue = assetUsdValue,
                assetDecimal = assetDecimal
            )
        }
    }
}
