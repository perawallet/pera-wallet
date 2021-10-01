/*
 * Copyright 2019 Algorand, Inc.
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

import com.google.gson.annotations.SerializedName
import java.math.BigInteger

data class AssetConfigParameters(
    @SerializedName("t") val totalSupply: BigInteger? = null,
    @SerializedName("dc") val decimal: Long? = null,
    @SerializedName("df") val isFrozen: Boolean? = null,
    @SerializedName("un") val unitName: String? = null,
    @SerializedName("an") val name: String? = null,
    @SerializedName("au") val url: String? = null,
    /** Base64 **/
    @SerializedName("am") val metadataHash: String? = null,
    @SerializedName("m") val managerAddress: String? = null,
    @SerializedName("r") val reserveAddress: String? = null,
    @SerializedName("f") val frozenAddress: String? = null,
    @SerializedName("c") val clawbackAddress: String? = null
)
