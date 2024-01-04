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

import com.google.gson.annotations.SerializedName
import java.math.BigInteger

data class SwapQuoteRequestBody(
    @SerializedName("providers")
    val providers: List<String>,
    @SerializedName("swapper_address")
    val swapperAddress: String,
    @SerializedName("swap_type")
    val swapType: SwapTypeResponse,
    @SerializedName("device")
    val deviceId: String,
    @SerializedName("asset_in_id")
    val assetInId: Long,
    @SerializedName("asset_out_id")
    val assetOutId: Long,
    @SerializedName("amount")
    val amount: BigInteger,
    @SerializedName("slippage")
    val slippage: Float?
)
