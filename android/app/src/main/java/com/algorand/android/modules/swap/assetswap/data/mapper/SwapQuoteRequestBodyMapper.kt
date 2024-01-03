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

import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.data.mapper.decider.SwapTypeResponseDecider
import com.algorand.android.modules.swap.assetswap.data.model.SwapQuoteRequestBody
import java.math.BigInteger
import javax.inject.Inject

class SwapQuoteRequestBodyMapper @Inject constructor(
    private val swapTypeResponseDecider: SwapTypeResponseDecider
) {

    fun mapToSwapQuoteRequestBody(
        providersList: List<String>,
        swapperAccountAddress: String,
        swapType: SwapType,
        deviceId: String,
        fromAssetId: Long,
        toAssetId: Long,
        amount: BigInteger,
        slippage: Float
    ): SwapQuoteRequestBody {
        return SwapQuoteRequestBody(
            providers = providersList,
            swapperAddress = swapperAccountAddress,
            swapType = swapTypeResponseDecider.decideSwapType(swapType),
            deviceId = deviceId,
            assetInId = fromAssetId,
            assetOutId = toAssetId,
            amount = amount,
            slippage = slippage
        )
    }
}
