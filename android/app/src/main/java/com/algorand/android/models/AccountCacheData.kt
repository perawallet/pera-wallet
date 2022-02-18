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
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.calculateMinBalance
import com.algorand.android.utils.getAccountImageResource
import com.algorand.android.utils.isRekeyedToAnotherAccount
import kotlinx.android.parcel.Parcelize

@Parcelize
data class AccountCacheData(
    val account: Account,
    val assetsInformation: MutableList<AssetInformation>,
    val accountInformation: AccountInformation
) : Parcelable {

    val authAddress: String?
        get() = accountInformation.rekeyAdminAddress

    fun isRekeyedToAnotherAccount(): Boolean {
        return isRekeyedToAnotherAccount(authAddress, account.address)
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
        return getAccountImageResource(account.type, isRekeyedToAnotherAccount())
    }

    fun getMinBalance(): Long {
        return calculateMinBalance(
            accountInformation,
            isRekeyedToAnotherAccount() || assetsInformation.isNotEmpty() || accountInformation.isThereAnOptedInApp()
        )
    }

    fun getAuthTypeAndDetail(): Account.Detail? {
        return when (val accountDetail = account.detail) {
            is Account.Detail.RekeyedAuth -> accountDetail.authDetail
            is Account.Detail.Standard -> accountDetail
            is Account.Detail.Ledger -> accountDetail
            else -> null
        }
    }

    fun getAssetInfoById(assetId: Long): String? {
        return assetsInformation.find { it.assetId == assetId }?.fullName
    }

    fun isThereAnyDifferentAsset() = assetsInformation.isNotEmpty()

    companion object {
        private const val ASSET_INSERTION_POSITION = 1

        fun create(
            accountCacheManager: AccountCacheManager,
            account: Account,
            accountInformation: AccountInformation
        ): AccountCacheData {
            return AccountCacheData(
                account,
                accountInformation.getAssetInformationList(accountCacheManager),
                accountInformation
            )
        }
    }
}
