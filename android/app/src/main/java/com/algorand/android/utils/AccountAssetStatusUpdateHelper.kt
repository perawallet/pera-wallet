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

package com.algorand.android.utils

import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AssetHolding
import com.algorand.android.models.AssetStatus
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject

class AccountAssetStatusUpdateHelper @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase
) {

    fun getAssetStatusUpdatedAccount(accountDetail: AccountDetail): AccountDetail {
        val cachedAccountAssetHoldings = accountDetailUseCase.getCachedAccountDetail(accountDetail.account.address)
            ?.data?.accountInformation?.assetHoldingList ?: return accountDetail
        val (pendingAssetAdditions, pendingAssetRemovals) = getPendingAssetHoldings(cachedAccountAssetHoldings)
        val assetRemovalsUpdatedAccount = handlePendingAssetRemovals(pendingAssetRemovals, accountDetail)
        return handlePendingAssetAdditions(pendingAssetAdditions, assetRemovalsUpdatedAccount)
    }

    private fun handlePendingAssetRemovals(
        pendingAssetRemovals: List<AssetHolding>,
        accountDetail: AccountDetail
    ): AccountDetail {
        pendingAssetRemovals.forEach { pendingAsset ->
            accountDetail.accountInformation.apply {
                assetHoldingList.firstOrNull { it.assetId == pendingAsset.assetId }?.status = pendingAsset.status
            }
        }
        return accountDetail
    }

    private fun handlePendingAssetAdditions(
        pendingAssetAdditions: List<AssetHolding>,
        accountDetail: AccountDetail
    ): AccountDetail {
        return accountDetail.apply {
            pendingAssetAdditions.forEach { assetHolding ->
                if (!accountInformation.assetHoldingList.any { it.assetId == assetHolding.assetId }) {
                    accountInformation.addPendingAssetHolding(assetHolding)
                }
            }
        }
    }

    private fun getPendingAssetHoldings(
        cachedAccountAssetHoldings: List<AssetHolding>
    ): Pair<List<AssetHolding>, List<AssetHolding>> {
        val pendingAssetAdditions = mutableListOf<AssetHolding>()
        val pendingAssetRemovals = mutableListOf<AssetHolding>()
        cachedAccountAssetHoldings.forEach { assetHolding ->
            when (assetHolding.status) {
                AssetStatus.PENDING_FOR_ADDITION -> pendingAssetAdditions.add(assetHolding)
                AssetStatus.PENDING_FOR_REMOVAL -> pendingAssetRemovals.add(assetHolding)
            }
        }
        return pendingAssetAdditions to pendingAssetRemovals
    }
}
