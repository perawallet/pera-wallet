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

package com.algorand.android.modules.swap.assetswap.domain.mapper

import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteAssetDetail
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteDTO
import java.math.BigDecimal
import javax.inject.Inject

class SwapQuoteMapper @Inject constructor() {

    @Suppress("LongParameterList")
    fun mapToSwapQuote(
        swapQuoteDTO: SwapQuoteDTO,
        quoteId: Long,
        swapType: SwapType,
        fromAssetDetail: SwapQuoteAssetDetail,
        toAssetDetail: SwapQuoteAssetDetail,
        fromAssetAmount: BigDecimal,
        toAssetAmount: BigDecimal,
        fromAssetAmountInUsdValue: BigDecimal,
        fromAssetAmountInSelectedCurrency: ParityValue,
        fromAssetAmountWithSlippage: BigDecimal,
        toAssetAmountInUsdValue: BigDecimal,
        toAssetAmountInSelectedCurrency: ParityValue,
        toAssetAmountWithSlippage: BigDecimal,
        slippage: Float,
        price: Float,
        priceImpact: Float,
        peraFeeAmount: BigDecimal,
        exchangeFeeAmount: BigDecimal,
        swapperAddress: String
    ): SwapQuote {
        return SwapQuote(
            quoteId = quoteId,
            provider = swapQuoteDTO.provider,
            swapType = swapType,
            deviceId = swapQuoteDTO.deviceId,
            accountAddress = swapperAddress,
            fromAssetDetail = fromAssetDetail,
            toAssetDetail = toAssetDetail,
            fromAssetAmount = fromAssetAmount,
            toAssetAmount = toAssetAmount,
            fromAssetAmountInUsdValue = fromAssetAmountInUsdValue,
            fromAssetAmountInSelectedCurrency = fromAssetAmountInSelectedCurrency,
            fromAssetAmountWithSlippage = fromAssetAmountWithSlippage,
            toAssetAmountInUsdValue = toAssetAmountInUsdValue,
            toAssetAmountInSelectedCurrency = toAssetAmountInSelectedCurrency,
            toAssetAmountWithSlippage = toAssetAmountWithSlippage,
            price = price,
            priceImpact = priceImpact,
            peraFeeAmount = peraFeeAmount,
            exchangeFeeAmount = exchangeFeeAmount,
            slippage = slippage
        )
    }
}
