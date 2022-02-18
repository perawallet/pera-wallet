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
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.Participation.Companion.DEFAULT_PARTICIPATION_KEY
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.calculateMinBalance
import java.math.BigInteger
import java.math.BigInteger.ZERO
import kotlinx.parcelize.Parcelize

@Parcelize
data class AccountInformation(
    val address: String,
    val amount: BigInteger,
    val rewards: Long,
    val pendingRewards: Long,
    val participation: Participation?,
    val rekeyAdminAddress: String?,
    private val allAssetHoldingList: MutableSet<AssetHolding>?,
    val createdAtRound: Long?,
    val amountWithoutPendingRewards: BigInteger,
    val createdApps: List<CreatedApps>? = null,
    val appsLocalState: List<CreatedAppLocalState>? = null,
    val appsTotalSchema: CreatedAppStateScheme? = null,
    val appsTotalExtraPages: Int? = null
) : Parcelable {

    val assetHoldingList: List<AssetHolding>
        get() = allAssetHoldingList?.filterNot { it.isDeleted } ?: listOf()

    fun isCreated(): Boolean {
        return createdAtRound != null
    }

    fun setAssetHoldingStatus(assetId: Long, status: AssetStatus) {
        allAssetHoldingList?.firstOrNull { it.assetId == assetId }?.status = status
    }

    fun addPendingAssetHolding(assetHolding: AssetHolding) {
        if (!AssetStatus.isPending(assetHolding.status)) return
        allAssetHoldingList?.add(assetHolding)
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

    fun getAllAssetIdsIncludeAlgorand(): List<Long> {
        return assetHoldingList.map { it.assetId }.toMutableList().apply { add(0, ALGORAND_ID) }
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
}
