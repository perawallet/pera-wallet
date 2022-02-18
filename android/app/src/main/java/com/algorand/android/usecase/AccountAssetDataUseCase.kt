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

package com.algorand.android.usecase

import com.algorand.android.mapper.AccountAssetDataMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.AssetStatus.OWNED_BY_ACCOUNT
import com.algorand.android.models.AssetStatus.PENDING_FOR_ADDITION
import com.algorand.android.models.AssetStatus.PENDING_FOR_REMOVAL
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.OwnedAssetData
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.mapNotNull

class AccountAssetDataUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val accountAssetDataMapper: AccountAssetDataMapper
) {

    fun getAccountOwnedAssetDataFlow(publicKey: String, includeAlgo: Boolean): Flow<List<OwnedAssetData>> {
        return accountDetailUseCase.getAccountDetailCacheFlow()
            .mapNotNull { it.getOrDefault(publicKey, null)?.data }
            .distinctUntilChanged()
            .mapNotNull { account -> createAccountOwnedAssetData(account, includeAlgo) }
    }

    fun getAccountAllAssetDataFlow(publicKey: String, includeAlgo: Boolean): Flow<List<BaseAccountAssetData>> {
        return accountDetailUseCase.getAccountDetailCacheFlow()
            .mapNotNull { it.getOrDefault(publicKey, null)?.data }
            .distinctUntilChanged()
            .mapNotNull { account -> createAccountAllAssetData(account, includeAlgo) }
    }

    fun getNonCachedAccountAssetData(accountDetail: AccountDetail, includeAlgo: Boolean): List<OwnedAssetData> {
        return createNonCachedAccountAssetData(accountDetail, includeAlgo)
    }

    fun getAccountOwnedAssetData(accountDetail: AccountDetail, includeAlgo: Boolean): List<OwnedAssetData> {
        return createAccountOwnedAssetData(accountDetail, includeAlgo)
    }

    fun getAccountOwnedAssetData(publicKey: String, includeAlgo: Boolean): List<OwnedAssetData> {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)?.data ?: return emptyList()
        return createAccountOwnedAssetData(accountDetail, includeAlgo)
    }

    private fun createAccountOwnedAssetData(account: AccountDetail, includeAlgo: Boolean): List<OwnedAssetData> {
        val accountOwnedAssetList = getAccountOwnedCachedAssetList(account)
        return createAssetDataList(account, includeAlgo, accountOwnedAssetList).filterIsInstance<OwnedAssetData>()
    }

    private fun createAccountAllAssetData(account: AccountDetail, includeAlgo: Boolean): List<BaseAccountAssetData> {
        val cachedAccountAllAssetList = getAccountAllCachedAssetList(account)
        return createAssetDataList(account, includeAlgo, cachedAccountAllAssetList)
    }

    private fun createAssetDataList(
        account: AccountDetail,
        includeAlgo: Boolean,
        cachedAssetList: List<AssetQueryItem>
    ): List<BaseAccountAssetData> {
        return mutableListOf<BaseAccountAssetData>().apply {
            if (includeAlgo) add(accountAlgoAmountUseCase.getAccountAlgoAmount(account.account.address))
            account.accountInformation.assetHoldingList.forEach { assetHolding ->
                cachedAssetList.firstOrNull { it.assetId == assetHolding.assetId }?.let { assetItem ->
                    val accountAssetData = when (assetHolding.status) {
                        OWNED_BY_ACCOUNT -> accountAssetAmountUseCase.getAssetAmount(assetHolding, assetItem)
                        PENDING_FOR_REMOVAL -> accountAssetDataMapper.mapToPendingRemovalAssetData(assetItem)
                        PENDING_FOR_ADDITION -> accountAssetDataMapper.mapToPendingAdditionAssetData(assetItem)
                    }
                    if (accountAssetData is OwnedAssetData) {
                        add(accountAssetData)
                    } else {
                        val insertIndex = if (includeAlgo) 1 else 0
                        add(insertIndex, accountAssetData)
                    }
                }
            }
        }
    }

    private fun getAccountOwnedCachedAssetList(account: AccountDetail): List<AssetQueryItem> {
        val accountOwnedAssetIdList = account.accountInformation.assetHoldingList.mapNotNull { assetHolding ->
            assetHolding.assetId.takeIf { assetHolding.status == OWNED_BY_ACCOUNT }
        }
        return assetDetailUseCase.getCachedAssetDetail(accountOwnedAssetIdList).mapNotNull { it.data }
    }

    private fun getAccountAllCachedAssetList(account: AccountDetail): List<AssetQueryItem> {
        val accountAssetIdList = account.accountInformation.assetHoldingList.map { it.assetId }
        return assetDetailUseCase.getCachedAssetDetail(accountAssetIdList).mapNotNull { it.data }
    }

    private fun createNonCachedAccountAssetData(account: AccountDetail, includeAlgo: Boolean): List<OwnedAssetData> {
        return mutableListOf<OwnedAssetData>().apply {
            if (includeAlgo) {
                add(accountAlgoAmountUseCase.getAccountAlgoAmount(account))
            }
            addAll(createAccountOtherAssetsData(account.accountInformation))
        }
    }

    private fun createAccountOtherAssetsData(accountInformation: AccountInformation): List<OwnedAssetData> {
        val cachedAssetList = getCachedAssetList(accountInformation)
        return mutableListOf<OwnedAssetData>().apply {
            accountInformation.assetHoldingList.forEach { assetHolding ->
                cachedAssetList.firstOrNull { it.assetId == assetHolding.assetId }?.let { assetItem ->
                    val accountAssetData = accountAssetAmountUseCase.getAssetAmount(assetHolding, assetItem)
                    add(accountAssetData)
                }
            }
        }
    }

    private fun getCachedAssetList(accountInformation: AccountInformation): List<AssetQueryItem> {
        val accountAssetHoldingList = accountInformation.getAllAssetIds()
        return assetDetailUseCase.getCachedAssetDetail(accountAssetHoldingList).mapNotNull { it.data }
    }
}
