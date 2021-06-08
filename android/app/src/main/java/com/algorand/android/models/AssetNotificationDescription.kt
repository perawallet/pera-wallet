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

import com.algorand.android.utils.ALGOS_FULL_NAME
import com.algorand.android.utils.ALGO_DECIMALS
import com.google.gson.annotations.SerializedName

// this data class will be only used in notification. (HIPO back-end stores asset like this)
data class AssetNotificationDescription(
    @SerializedName("asset_id")
    val assetId: Long,
    @SerializedName("asset_name")
    val fullName: String? = null,
    @SerializedName("unit_name")
    val shortName: String? = null,
    @SerializedName("url")
    val url: String? = null,
    @SerializedName("fraction_decimals")
    val decimals: Int?,
    val isVerified: Boolean = false
) {

    fun convertToAssetInformation(): AssetInformation {
        return AssetInformation(
            assetId = assetId,
            isVerified = isVerified,
            shortName = shortName,
            fullName = fullName,
            decimals = decimals ?: 0
        )
    }

    companion object {
        fun getAlgorandNotificationDescription(): AssetNotificationDescription {
            return AssetNotificationDescription(
                assetId = AssetInformation.ALGORAND_ID,
                isVerified = true,
                fullName = ALGOS_FULL_NAME,
                decimals = ALGO_DECIMALS
            )
        }
    }
}
