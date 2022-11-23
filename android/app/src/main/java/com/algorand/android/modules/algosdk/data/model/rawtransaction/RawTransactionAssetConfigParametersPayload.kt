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

package com.algorand.android.modules.algosdk.data.model.rawtransaction

import com.google.gson.annotations.SerializedName

data class RawTransactionAssetConfigParametersPayload(
    @SerializedName("t") val totalSupply: String?,
    @SerializedName("dc") val decimal: Long?,
    @SerializedName("df") val isFrozen: Boolean?,
    @SerializedName("un") val unitName: String?,
    @SerializedName("an") val name: String?,
    @SerializedName("au") val url: String?,
    @SerializedName("am") val metadataHash: String?,
    @SerializedName("m") val managerAddress: String?,
    @SerializedName("r") val reserveAddress: String?,
    @SerializedName("f") val frozenAddress: String?,
    @SerializedName("c") val clawbackAddress: String?
)
