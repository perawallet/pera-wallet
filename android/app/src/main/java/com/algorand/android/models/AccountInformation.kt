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
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
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
    val participation: Participation?,
    val rekeyAdminAddress: String?,
    private val allAssetHoldingMap: HashMap<Long, AssetHolding>,
    val createdAtRound: Long?,
    val appsLocalState: List<CreatedAppLocalState>? = null,
    val appsTotalSchema: CreatedAppStateScheme? = null,
    val appsTotalExtraPages: Int? = null,
    val totalCreatedApps: Int = 0,
    val lastFetchedRound: Long?
) : Parcelable {

    val assetHoldingMap: HashMap<Long, AssetHolding>
        get() = allAssetHoldingMap?.filterNot { it.value.isDeleted } as? HashMap<Long, AssetHolding> ?: hashMapOf()

    fun isCreated(): Boolean {
        return createdAtRound != null
    }

    fun setAssetHoldingStatus(assetId: Long, status: AssetStatus) {
        allAssetHoldingMap?.get(assetId)?.status = status
    }

    fun addPendingAssetHolding(assetHolding: AssetHolding) {
        if (!AssetStatus.isPending(assetHolding.status)) return
        allAssetHoldingMap?.put(assetHolding.assetId, assetHolding)
    }

    fun isRekeyed(): Boolean {
        return !rekeyAdminAddress.isNullOrEmpty() && rekeyAdminAddress != address
    }

    fun getAssetInformationList(accountCacheManager: AccountCacheManager): MutableList<AssetInformation> {
        val assetInformationList = mutableListOf<AssetInformation>()
        assetInformationList.add(
            AssetInformation.getAlgorandAsset(amount)
        )
        assetHoldingMap.values.forEach { assetHolding ->
            accountCacheManager.getAssetDescription(assetHolding.assetId)?.let { assetDescription ->
                assetInformationList.add(AssetInformation.createAssetInformation(assetHolding, assetDescription))
            }
        }
        return assetInformationList
    }

    fun getAllAssetIds(): List<Long> {
        return assetHoldingMap.keys.toList()
    }

    fun getAllAssetIdsIncludeAlgorand(): List<Long> {
        return getAllAssetIds().toMutableList().apply { add(0, ALGO_ID) }
    }

    fun getOptedInAssetsCount() = allAssetHoldingMap?.size ?: 0

    fun getMinAlgoBalance(): BigInteger {
        return calculateMinBalance(
            this,
            isRekeyed() || isThereAnyDifferentAsset() || isThereAnOptedInApp()
        ).toBigInteger()
    }

    fun isAssetSupported(assetId: Long): Boolean {
        return assetId == ALGO_ID || hasAsset(assetId)
    }

    fun getBalance(assetId: Long): BigInteger {
        return if (assetId == ALGO_ID) {
            amount
        } else {
            getAssetHoldingOrNull(assetId)?.amount ?: ZERO
        }
    }

    fun doesUserHasParticipationKey() =
        !(participation == null || participation.voteParticipationKey == DEFAULT_PARTICIPATION_KEY)

    fun isThereAnyDifferentAsset() = assetHoldingMap.isNotEmpty()

    fun isThereAnOptedInApp() = appsLocalState?.isNotEmpty() == true || totalCreatedApps > 0

    fun hasAsset(assetId: Long): Boolean {
        return assetHoldingMap.containsKey(assetId)
    }

    fun getAssetHoldingOrNull(assetId: Long): AssetHolding? {
        return assetHoldingMap.get(assetId)
    }

    fun getAssetStatusOrNull(assetId: Long): AssetStatus? {
        return getAssetHoldingOrNull(assetId)?.status
    }

    fun getAssetHoldingList(): List<AssetHolding> {
        return assetHoldingMap.values.toList()
    }

    fun getAssetIdList(): List<Long> {
        return assetHoldingMap.keys.toList()
    }
}
