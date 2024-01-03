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

package com.algorand.android.modules.swap.assetswap.domain.model.dto

import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteProvider
import java.math.BigDecimal

data class SwapQuoteDTO(
    val id: Long?,
    val provider: SwapQuoteProvider?,
    val swapType: SwapType?,
    val swapperAddress: String?,
    val deviceId: Long?,
    val assetInAssetDetail: SwapQuoteAssetDetailDTO?,
    val assetOutAssetDetail: SwapQuoteAssetDetailDTO?,
    val assetInAmount: String?,
    val assetInAmountInUsdValue: String?,
    val assetInAmountWithSlippage: String?,
    val assetOutAmount: String?,
    val assetOutAmountInUsdValue: String?,
    val assetOutAmountWithSlippage: String?,
    val slippage: String?,
    val price: String?,
    val priceImpact: String?,
    val peraFeeAmount: BigDecimal?,
    val exchangeFeeAmount: BigDecimal?
)
