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
import com.algorand.android.R
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.minBalancePerAssetAsBigInteger
import java.math.BigInteger
import kotlinx.android.parcel.Parcelize

@Parcelize
data class AccountCacheData(
    val account: Account,
    val authAddress: String? = null,
    val assetsInformation: MutableList<AssetInformation>
) : Parcelable {

    fun isRekeyedToAnotherAccount(): Boolean {
        return !authAddress.isNullOrBlank() && authAddress != account.address
    }

    fun addAssetsPendingForAddition(previousAssets: List<AssetInformation>?) {
        previousAssets
            ?.filter { it.assetStatus == AssetStatus.PENDING_FOR_ADDITION }
            ?.forEach { pendingItem -> addPendingAsset(pendingItem) }
    }

    fun addPendingAsset(pendingAsset: AssetInformation) {
        if (assetsInformation.none { pendingAsset.assetId == it.assetId }) {
            assetsInformation.add(ASSET_INSERTION_POSITION, pendingAsset)
        }
    }

    fun addAssetsPendingForRemoval(previousAssets: List<AssetInformation>?) {
        previousAssets
            ?.filter { it.assetStatus == AssetStatus.PENDING_FOR_REMOVAL }
            ?.forEach { assetPendingRemoval -> changeAssetStatusToRemovalPending(assetPendingRemoval.assetId) }
    }

    fun changeAssetStatusToRemovalPending(assetId: Long) {
        assetsInformation.firstOrNull { it.assetId == assetId }?.assetStatus = AssetStatus.PENDING_FOR_REMOVAL
    }

    fun getImageResource(): Int {
        if (account.type != Account.Type.WATCH && isRekeyedToAnotherAccount()) {
            return R.drawable.ic_rekeyed_ledger
        }
        return when (account.type) {
            Account.Type.STANDARD -> R.drawable.ic_standard_account
            Account.Type.LEDGER -> R.drawable.ic_ledger_vectorized
            Account.Type.WATCH -> R.drawable.ic_watch_account
            else -> R.drawable.ic_ledger_vectorized
        }
    }

    fun getMinBalance(): BigInteger {
        val assetCount = assetsInformation.size
        return minBalancePerAssetAsBigInteger.multiply(assetCount.toBigInteger())
    }

    fun getAuthTypeAndDetail(): Account.Detail? {
        return when (val accountDetail = account.detail) {
            is Account.Detail.RekeyedAuth -> accountDetail.authDetail
            is Account.Detail.Standard -> accountDetail
            is Account.Detail.Ledger -> accountDetail
            else -> null
        }
    }

    companion object {
        private const val ASSET_INSERTION_POSITION = 1

        fun create(
            accountCacheManager: AccountCacheManager,
            account: Account,
            accountInformation: AccountInformation
        ): AccountCacheData {
            return AccountCacheData(
                account,
                accountInformation.rekeyAdminAddress,
                accountInformation.getAssetInformationList(accountCacheManager)
            )
        }
    }
}
