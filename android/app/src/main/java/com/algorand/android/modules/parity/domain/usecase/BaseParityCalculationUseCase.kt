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
import com.algorand.android.models.AssetHolding
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.modules.parity.domain.mapper.ParityValueMapper
import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import java.math.BigDecimal
import java.math.BigInteger

abstract class BaseParityCalculationUseCase(
    private val parityValueMapper: ParityValueMapper
) : BaseUseCase() {

    abstract fun getAssetParityValue(assetHolding: AssetHolding, assetItem: BaseAssetDetail): ParityValue
    abstract fun getAssetParityValue(assetAmount: BigInteger, assetUsdValue: BigDecimal, assetDecimal: Int): ParityValue
    abstract fun getAlgoParityValue(algoAmount: BigInteger): ParityValue

    protected fun calculateParityValue(
        assetUsdValue: BigDecimal?,
        assetDecimals: Int?,
        amount: BigInteger,
        conversionRate: BigDecimal?,
        currencySymbol: String
    ): ParityValue {
        val safeAssetUsdValue = assetUsdValue ?: BigDecimal.ZERO
        val safeDecimal = assetDecimals ?: DEFAULT_ASSET_DECIMAL
        val amountInSelectedCurrency = amount.toBigDecimal().movePointLeft(safeDecimal)
            .multiply(conversionRate ?: BigDecimal.ZERO)
            .multiply(safeAssetUsdValue)
        return parityValueMapper.mapToParityValue(amountInSelectedCurrency, currencySymbol)
    }
}
