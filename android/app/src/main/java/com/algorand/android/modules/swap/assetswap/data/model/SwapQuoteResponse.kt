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

package com.algorand.android.modules.swap.assetswap.data.model

import com.algorand.android.modules.swap.assetselection.toasset.data.model.SwapQuoteProviderResponse
import com.google.gson.annotations.SerializedName
import java.math.BigDecimal

data class SwapQuoteResponse(
    @SerializedName("id")
    val id: Long?,
    @SerializedName("provider")
    val provider: SwapQuoteProviderResponse?,
    @SerializedName("swap_type")
    val swapType: SwapTypeResponse?,
    @SerializedName("swapper_address")
    val swapperAddress: String?,
    @SerializedName("device")
    val deviceId: Long?,
    @SerializedName("asset_in")
    val assetInAssetDetailResponse: SwapQuoteAssetDetailResponse?,
    @SerializedName("asset_out")
    val assetOutAssetDetailResponse: SwapQuoteAssetDetailResponse?,
    @SerializedName("amount_in")
    val assetInAmount: String?,
    @SerializedName("amount_in_with_slippage")
    val assetInAmountWithSlippage: String?,
    @SerializedName("amount_in_usd_value")
    val assetInAmountInUsdValue: String?,
    @SerializedName("amount_out")
    val assetOutAmount: String?,
    @SerializedName("amount_out_with_slippage")
    val assetOutAmountWithSlippage: String?,
    @SerializedName("amount_out_usd_value")
    val assetOutAmountInUsdValue: String?,
    @SerializedName("slippage")
    val slippage: String?,
    @SerializedName("price")
    val price: String?,
    @SerializedName("price_impact")
    val priceImpact: String?,
    @SerializedName("pera_fee_amount")
    val peraFeeAmount: BigDecimal?,
    @SerializedName("exchange_fee_amount")
    val exchangeFeeAmount: BigDecimal?
)
