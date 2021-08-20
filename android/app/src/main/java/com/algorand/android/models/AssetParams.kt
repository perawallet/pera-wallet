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

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
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
    val total: Long? = null,
    @SerializedName("reserve")
    val reserve: String? = null,
    @SerializedName("clawback")
    val clawback: String? = null,
    var id: Long? = null,
    var isVerified: Boolean = false
) : Parcelable {

    fun convertToAssetInformation(
        assetId: Long
    ): AssetInformation {
        return AssetInformation(
            assetId = assetId,
            isVerified = isVerified,
            creatorPublicKey = creatorPublicKey,
            shortName = shortName,
            fullName = fullName,
            url = url
        )
    }

    fun appendAssetId(assetId: Long): AssetParams {
        id = assetId
        return this
    }
}
