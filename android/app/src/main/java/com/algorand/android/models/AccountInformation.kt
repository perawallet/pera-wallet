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
import com.algorand.android.models.Participation.Companion.DEFAULT_PARTICIPATION_KEY
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.calculateMinBalance
import com.google.gson.annotations.SerializedName
import java.math.BigInteger
import java.math.BigInteger.ZERO
import kotlinx.parcelize.Parcelize

@Parcelize
data class AccountInformation(
    @SerializedName("address") val address: String,
    @SerializedName("amount") val amount: BigInteger,
    @SerializedName("rewards") val rewards: Long,
    @SerializedName("pending-rewards") val pendingRewards: Long,
    @SerializedName("participation") val participation: Participation?,
    @SerializedName("auth-addr") val rekeyAdminAddress: String?,
    @SerializedName("assets") private val allAssetHoldingList: List<AssetHolding>?,
    @SerializedName("created-at-round") val createdAtRound: Long?,
    @SerializedName("amount-without-pending-rewards") val amountWithoutPendingRewards: BigInteger,
    @SerializedName("created-apps") val createdApps: List<CreatedApps>? = null,
    @SerializedName("apps-local-state") val appsLocalState: List<CreatedAppLocalState>? = null,
    @SerializedName("apps-total-schema") val appsTotalSchema: CreatedAppStateScheme? = null,
    @SerializedName("apps-total-extra-pages") val appsTotalExtraPages: Int? = null
) : Parcelable {

    private val assetHoldingList: List<AssetHolding>
        get() = allAssetHoldingList?.filterNot { it.isDeleted } ?: listOf()

    fun isCreated(): Boolean {
        return createdAtRound != null
    }

    fun isRekeyed(): Boolean {
        return !rekeyAdminAddress.isNullOrEmpty() && rekeyAdminAddress != address
    }

    fun getAssetInformationList(accountCacheManager: AccountCacheManager): MutableList<AssetInformation> {
        val assetInformationList = mutableListOf<AssetInformation>()
        assetInformationList.add(
            AssetInformation.getAlgorandAsset(
                amount,
                rewards,
                pendingRewards,
                amountWithoutPendingRewards
            )
        )
        assetHoldingList.forEach { assetHolding ->
            accountCacheManager.getAssetDescription(assetHolding.assetId)?.let { assetDescription ->
                assetInformationList.add(AssetInformation.createAssetInformation(assetHolding, assetDescription))
            }
        }
        return assetInformationList
    }

    fun getAllAssetIds(): List<Long> {
        return assetHoldingList.map { it.assetId }
    }

    fun getOptedInAssetsCount() = allAssetHoldingList?.size ?: 0

    fun getMinAlgoBalance(): BigInteger {
        return calculateMinBalance(
            this,
            isRekeyed() || isThereAnyDifferentAsset() || isThereAnOptedInApp()
        ).toBigInteger()
    }

    fun isAssetSupported(assetId: Long): Boolean {
        return assetId == AssetInformation.ALGORAND_ID || assetHoldingList.any { it.assetId == assetId }
    }

    fun getBalance(assetId: Long): BigInteger {
        return if (assetId == AssetInformation.ALGORAND_ID) {
            amount
        } else {
            assetHoldingList.firstOrNull { it.assetId == assetId }?.amount ?: ZERO
        }
    }

    fun doesUserHasParticipationKey() =
        !(participation == null || participation.voteParticipationKey == DEFAULT_PARTICIPATION_KEY)

    fun isThereAnyDifferentAsset() = assetHoldingList.isNotEmpty()

    fun isThereAnOptedInApp() = appsLocalState?.isNotEmpty() == true || createdApps?.isNotEmpty() == true

    companion object {
        fun emptyAccountInformation(accountPublicKey: String): AccountInformation {
            return AccountInformation(accountPublicKey, ZERO, 0, 0, Participation(), null, listOf(), null, ZERO)
        }
    }
}
