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

package com.algorand.android.modules.assets.profile.about.domain.usecase

import com.algorand.android.mapper.AssetHoldingsMapper
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.modules.parity.domain.usecase.PrimaryCurrencyParityCalculationUseCase
import com.algorand.android.modules.parity.domain.usecase.SecondaryCurrencyParityCalculationUseCase
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class GetSelectedAssetExchangeValueUseCase @Inject constructor(
    private val primaryCurrencyParityCalculationUseCase: PrimaryCurrencyParityCalculationUseCase,
    private val secondaryCurrencyParityCalculationUseCase: SecondaryCurrencyParityCalculationUseCase,
    private val assetHoldingsMapper: AssetHoldingsMapper,
    private val currencyUseCase: CurrencyUseCase
) {

    fun getSelectedAssetExchangeValue(assetDetail: AssetDetail): ParityValue {
        return if (assetDetail.assetId == ALGO_ID) {
            getAlgoExchangeParityValue()
        } else {
            getAssetExchangeParityValue(assetDetail)
        }
    }

    private fun getAlgoExchangeParityValue(): ParityValue {
        val isPrimaryCurrencyAlgo = currencyUseCase.isPrimaryCurrencyAlgo()
        val oneAlgoInBigInteger = createOneSelectedAssetInBigInteger(ALGO_DECIMALS)
        return if (isPrimaryCurrencyAlgo) {
            secondaryCurrencyParityCalculationUseCase.getAlgoParityValue(oneAlgoInBigInteger)
        } else {
            primaryCurrencyParityCalculationUseCase.getAlgoParityValue(oneAlgoInBigInteger)
        }
    }

    private fun getAssetExchangeParityValue(assetDetail: AssetDetail): ParityValue {
        val assetHolding = assetHoldingsMapper.mapToAssetHoldings(
            assetId = assetDetail.assetId,
            amount = createOneSelectedAssetInBigInteger(assetDetail.fractionDecimals),
            isDeleted = false
        )
        return primaryCurrencyParityCalculationUseCase.getAssetParityValue(
            assetItem = assetDetail,
            assetHolding = assetHolding
        )
    }

    private fun createOneSelectedAssetInBigInteger(fractionDecimals: Int?): BigInteger {
        return BigDecimal.ONE.movePointRight(fractionDecimals ?: DEFAULT_ASSET_DECIMAL).toBigInteger()
    }
}
