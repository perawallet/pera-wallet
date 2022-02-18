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
import com.algorand.android.utils.ALGOS_FULL_NAME
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.ALGO_DECIMALS
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

    fun isAlgo(): Boolean {
        return assetId == ALGORAND_ID
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
                shortName = ALGOS_SHORT_NAME,
                decimals = ALGO_DECIMALS,
                amount = amount,
                totalRewards = totalRewards,
                pendingRewards = pendingRewards,
                isVerified = true,
                amountWithoutPendingRewards = amountWithoutPendingRewards
            )
        }

        fun createAssetInformation(assetHolding: AssetHolding, assetParams: AssetQueryItem): AssetInformation {
            return AssetInformation(
                assetId = assetHolding.assetId,
                isVerified = assetParams.isVerified,
                creatorPublicKey = assetParams.assetCreator?.publicKey,
                shortName = assetParams.shortName,
                fullName = assetParams.fullName,
                amount = assetHolding.amount,
                decimals = assetParams.fractionDecimals ?: 0
            )
        }

        // TODO Remove this function after changing RemoveAssetFlow
        fun createAssetInformation(accountAssetData: BaseAccountAssetData.OwnedAssetData): AssetInformation {
            return AssetInformation(
                assetId = accountAssetData.id,
                isVerified = accountAssetData.isVerified,
                creatorPublicKey = accountAssetData.creatorPublicKey,
                shortName = accountAssetData.shortName,
                fullName = accountAssetData.name,
                amount = accountAssetData.amount,
                decimals = accountAssetData.decimals
            )
        }
    }
}
