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

import android.os.Parcelable
import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.google.gson.annotations.SerializedName
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

@Parcelize
data class AssetParams(
    @SerializedName("unit-name")
    val shortName: String?,
    @SerializedName("name")
    val fullName: String?,
    @SerializedName("decimals")
    val decimals: Int?,
    @SerializedName("creator")
    val creatorPublicKey: String?,
    @SerializedName("url")
    val url: String? = null,
    @SerializedName("manager")
    val manager: String? = null,
    @SerializedName("freeze")
    val freeze: String? = null,
    @SerializedName("total")
    val maxSupply: BigInteger? = null,
    @SerializedName("reserve")
    val reserve: String? = null,
    @SerializedName("clawback")
    val clawback: String? = null,
    var id: Long? = null,
    val verificationTier: VerificationTier? = null
) : Parcelable {

    fun appendAssetId(assetId: Long): AssetParams {
        id = assetId
        return this
    }
}
