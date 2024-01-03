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

import com.algorand.android.models.VerificationTierResponse
import com.google.gson.annotations.SerializedName
import java.math.BigInteger

data class SwapQuoteAssetDetailResponse(
    @SerializedName("asset_id")
    val assetId: Long?,
    @SerializedName("logo")
    val logoUrl: String?,
    @SerializedName("name")
    val name: String?,
    @SerializedName("unit_name")
    val shortName: String?,
    @SerializedName("total")
    val total: BigInteger?,
    @SerializedName("fraction_decimals")
    val fractionDecimals: Int?,
    @SerializedName("verification_tier")
    val verificationTierResponse: VerificationTierResponse?,
    @SerializedName("usd_value")
    val usdValue: String?
)
