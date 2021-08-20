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

import android.content.Context
import android.content.res.Resources
import android.os.Parcelable
import android.text.SpannedString
import androidx.core.text.buildSpannedString
import com.algorand.android.R
import com.algorand.android.utils.ALGOS_FULL_NAME
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.addAlgorandIcon
import com.algorand.android.utils.addAssetId
import com.algorand.android.utils.addAssetName
import com.algorand.android.utils.addVerifiedIcon
import com.algorand.android.utils.formatAmount
import java.math.BigInteger
import kotlinx.android.parcel.IgnoredOnParcel
import kotlinx.parcelize.Parcelize

@Parcelize
data class AssetInformation(
    val assetId: Long,
    val isVerified: Boolean,
    val creatorPublicKey: String? = null,
    val shortName: String? = null,
    val fullName: String? = null,
    val amount: BigInteger? = null,
    val decimals: Int = 0,
    val totalRewards: Long? = null,
    val pendingRewards: Long? = null,
    var assetStatus: AssetStatus = AssetStatus.OWNED_BY_ACCOUNT,
    val amountWithoutPendingRewards: BigInteger? = null,
    val url: String? = null
) : Parcelable {

    @IgnoredOnParcel
    val formattedAmount by lazy { amount.formatAmount(decimals) }

    fun isAlgorand(): Boolean {
        return assetId == ALGORAND_ID
    }

    fun getAssetText(
        context: Context,
        showId: Boolean = false,
        idTextColor: Int? = null,
        showAlgorandLogo: Boolean = false,
        showTickerWithFullName: Boolean = true,
        verifiedIconRes: Int = R.drawable.ic_verified_asset
    ): SpannedString {
        return buildSpannedString {
            if (isVerified) {
                addVerifiedIcon(context, verifiedIconRes)
            }
            if (showAlgorandLogo && isAlgorand()) {
                addAlgorandIcon(context)
            }
            addAssetName(context, fullName, shortName, showTickerWithFullName)
            if (showId) {
                addAssetId(context, assetId, idTextColor)
            }
        }
    }

    fun getTickerText(resources: Resources): String {
        return if (isAlgorand()) {
            fullName.orEmpty()
        } else {
            shortName ?: resources.getString(R.string.unnamed)
        }
    }

    fun isAssetPending(): Boolean {
        return assetStatus != AssetStatus.OWNED_BY_ACCOUNT
    }

    companion object {
        const val ALGORAND_ID = -7L

        fun getAlgorandAsset(
            amount: BigInteger = BigInteger.ZERO,
            totalRewards: Long = 0,
            pendingRewards: Long = 0,
            amountWithoutPendingRewards: BigInteger = BigInteger.ZERO
        ): AssetInformation {
            return AssetInformation(
                assetId = ALGORAND_ID,
                fullName = ALGOS_FULL_NAME,
                decimals = ALGO_DECIMALS,
                amount = amount,
                totalRewards = totalRewards,
                pendingRewards = pendingRewards,
                isVerified = true,
                amountWithoutPendingRewards = amountWithoutPendingRewards
            )
        }

        fun createAssetInformation(assetHolding: AssetHolding, assetParams: AssetParams): AssetInformation {
            return AssetInformation(
                assetId = assetHolding.assetId,
                isVerified = assetParams.isVerified,
                creatorPublicKey = assetParams.creatorPublicKey,
                shortName = assetParams.shortName,
                fullName = assetParams.fullName,
                amount = assetHolding.amount,
                decimals = assetParams.decimals ?: 0,
                url = assetParams.url
            )
        }
    }
}
