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

package com.algorand.android.models

import com.algorand.android.nft.data.model.CollectibleResponse
import com.google.gson.annotations.SerializedName
import java.math.BigDecimal
import java.math.BigInteger

data class AssetDetailResponse(
    @SerializedName("asset_id") val assetId: Long,
    @SerializedName("name") val fullName: String?,
    @SerializedName("unit_name") val shortName: String?,
    @SerializedName("is_verified") val isVerified: Boolean = false,
    @SerializedName("fraction_decimals") val fractionDecimals: Int?,
    @SerializedName("usd_value") val usdValue: BigDecimal?,
    @SerializedName("creator") val assetCreator: AssetCreator?,
    @SerializedName("collectible") val collectible: CollectibleResponse?,
    @SerializedName("total") val totalSupply: BigInteger?
)
