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
import java.math.BigInteger
import javax.inject.Inject

/**
If Primary currency is Algo > App always display the $ as secondary currency.
If Primary currency is other than Algo > App always display Algo as secondary currency
 */
class SecondaryCurrencyParityCalculationUseCase @Inject constructor(
    private val parityUseCase: ParityUseCase,
    parityValueMapper: ParityValueMapper
) : BaseParityCalculationUseCase(parityValueMapper) {

    override fun getAssetParityValue(assetHolding: AssetHolding, assetItem: BaseAssetDetail): ParityValue {
        return calculateParityValue(
            assetUsdValue = assetItem.usdValue,
            assetDecimals = assetItem.fractionDecimals,
            amount = assetHolding.amount,
            conversionRate = parityUseCase.getUsdToSecondaryCurrencyConversionRate(),
            currencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        )
    }

    override fun getAlgoParityValue(algoAmount: BigInteger): ParityValue {
        val algoToUsdConversionRate = parityUseCase.getAlgoToUsdConversionRate()
        return calculateParityValue(
            assetUsdValue = algoToUsdConversionRate,
            assetDecimals = ALGO_DECIMALS,
            amount = algoAmount,
            conversionRate = parityUseCase.getUsdToSecondaryCurrencyConversionRate(),
            currencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        )
    }
}
