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

package com.algorand.android.modules.swap.assetswap.data.mapper

import com.algorand.android.modules.swap.assetswap.data.mapper.decider.SwapAssetDetailProviderDecider
import com.algorand.android.modules.swap.assetswap.data.mapper.decider.SwapTypeDecider
import com.algorand.android.modules.swap.assetswap.data.model.SwapQuoteResponse
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteDTO
import javax.inject.Inject

class SwapQuoteDTOMapper @Inject constructor(
    private val swapQuoteAssetDetailDTOMapper: SwapQuoteAssetDetailDTOMapper,
    private val swapTypeDecider: SwapTypeDecider,
    private val swapQuoteProviderDecider: SwapAssetDetailProviderDecider
) {

    fun mapToSwapQuoteDTO(response: SwapQuoteResponse): SwapQuoteDTO {
        return SwapQuoteDTO(
            id = response.id,
            provider = swapQuoteProviderDecider.decideSwapAssetDetailProvider(response.provider),
            swapType = swapTypeDecider.decideSwapType(response.swapType),
            swapperAddress = response.swapperAddress,
            deviceId = response.deviceId,
            assetInAssetDetail = swapQuoteAssetDetailDTOMapper
                .mapToSwapQuoteAssetDetailDTO(response.assetInAssetDetailResponse),
            assetOutAssetDetail = swapQuoteAssetDetailDTOMapper
                .mapToSwapQuoteAssetDetailDTO(response.assetOutAssetDetailResponse),
            assetInAmount = response.assetInAmount,
            assetInAmountInUsdValue = response.assetInAmountInUsdValue,
            assetInAmountWithSlippage = response.assetInAmountWithSlippage,
            assetOutAmount = response.assetOutAmount,
            assetOutAmountInUsdValue = response.assetOutAmountInUsdValue,
            assetOutAmountWithSlippage = response.assetOutAmountWithSlippage,
            slippage = response.slippage,
            price = response.price,
            priceImpact = response.priceImpact,
            peraFeeAmount = response.peraFeeAmount,
            exchangeFeeAmount = response.exchangeFeeAmount
        )
    }
}
