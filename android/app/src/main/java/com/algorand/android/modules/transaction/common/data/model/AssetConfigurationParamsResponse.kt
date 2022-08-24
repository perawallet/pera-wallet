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

package com.algorand.android.modules.transaction.common.data.model

import com.google.gson.annotations.SerializedName
import java.math.BigInteger

data class AssetConfigurationParamsResponse(
    @SerializedName("creator")
    val creator: String?,
    @SerializedName("decimals")
    val decimals: BigInteger?,
    @SerializedName("default-frozen")
    val defaultFrozen: Boolean?,
    @SerializedName("metadata-hash")
    val metadataHash: String?,
    @SerializedName("name")
    val name: String?,
    @SerializedName("name-b64")
    val nameB64: String?,
    @SerializedName("total")
    val total: BigInteger?,
    @SerializedName("unit-name")
    val unitName: String?,
    @SerializedName("unit-name-b64")
    val unitNameB64: String?,
    @SerializedName("url")
    val url: String?,
    @SerializedName("url-b64")
    val urlB64: String?
)
