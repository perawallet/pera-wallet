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

package com.algorand.android.utils

import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetParams
import com.algorand.android.models.VerifiedAssetDetail
import java.math.BigInteger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.transformLatest
import kotlinx.coroutines.withContext

class AccountCacheManager(private val accountManager: AccountManager) {

    private val assetDescriptionMap = mutableMapOf<Long, AssetParams>()
    private var verifiedAssetList: List<VerifiedAssetDetail> = listOf()
    val accountCacheMap = MutableStateFlow<Map<String, AccountCacheData>>(emptyMap())

    suspend fun setAccountBalanceInformation(account: Account, accountInformation: AccountInformation) {
        withContext(Dispatchers.Default) {
            if (accountManager.getAccount(account.address) != null) {
                val previousCacheData = accountCacheMap.value[account.address]
                val previousAssetList = previousCacheData?.assetsInformation
                val accountCacheData = AccountCacheData.create(
                    this@AccountCacheManager,
                    account.copy(), // TODO find a way to use flow here.
                    accountInformation
                ).apply {
                    addAssetsPendingForAddition(previousAssetList)
                    addAssetsPendingForRemoval(previousAssetList)
                }
                if (accountCacheData != previousCacheData) {
                    addCacheData(account.address, accountCacheData)
                }
            } else {
                removeCacheData(account.address)
            }
        }
    }

    fun getCacheStatusFlow(): Flow<AccountCacheStatus> {
        val cacheSizeFlow = accountCacheMap.transformLatest { emit(it.size) }.distinctUntilChanged()
        return accountManager.accounts.combine(cacheSizeFlow) { accounts, cachedAccountSize ->
            return@combine when {
                cachedAccountSize < accounts.size -> {
                    AccountCacheStatus.LOADING
                }
                else -> {
                    AccountCacheStatus.DONE
                }
            }
        }
    }

    fun getBalanceFlow(address: String, assetId: Long): Flow<BigInteger?> {
        return accountCacheMap
            .map { map -> map[address]?.assetsInformation?.firstOrNull { it.assetId == assetId }?.amount }
            .distinctUntilChanged()
    }

    fun getAssetInformationFlow(address: String, assetId: Long): Flow<AssetInformation?> {
        return accountCacheMap
            .map { map -> map[address]?.assetsInformation?.firstOrNull { it.assetId == assetId } }
            .distinctUntilChanged()
    }

    fun removeAllData() {
        accountCacheMap.value = mutableMapOf()
    }

    fun setAssetDescription(assetId: Long, assetParams: AssetParams) {
        assetDescriptionMap[assetId] = assetParams.apply { isVerified = isAssetVerified(assetId) }
    }

    fun isThereDescriptionForAsset(assetId: Long): Boolean {
        return assetDescriptionMap.contains(assetId)
    }

    fun getAssetDescription(assetId: Long): AssetParams? {
        return assetDescriptionMap[assetId]
    }

    fun addAssetToAccount(accountPublicKey: String, assetInformation: AssetInformation) {
        val newMap = accountCacheMap.value.toMutableMap()
        if (newMap[accountPublicKey]?.addPendingAsset(assetInformation) != null) {
            accountCacheMap.value = newMap
        }
    }

    fun changeAssetStatusToPendingRemoval(accountPublicKey: String, assetId: Long) {
        val newMap = accountCacheMap.value.toMutableMap()
        newMap[accountPublicKey]?.changeAssetStatusToRemovalPending(assetId)
        accountCacheMap.value = newMap
    }

    private fun addCacheData(accountPublicKey: String, cacheData: AccountCacheData) {
        val newMap = accountCacheMap.value.toMutableMap()
        newMap[accountPublicKey] = cacheData
        accountCacheMap.value = newMap
    }

    fun addAssetInformationToAccountCache(accountPublicKey: String, assetInformation: AssetInformation) {
        accountCacheMap.value[accountPublicKey]?.assetsInformation?.add(assetInformation)
    }

    fun removeCacheData(accountPublicKey: String) {
        val newMap = accountCacheMap.value.toMutableMap()
        newMap.remove(accountPublicKey)
        accountCacheMap.value = newMap
    }

    fun getAssetInformation(accountPublicKey: String, assetId: Long): AssetInformation? {
        return accountCacheMap.value[accountPublicKey]?.assetsInformation?.firstOrNull { assetId == it.assetId }
    }

    fun getAccountCacheWithSpecificAsset(
        assetId: Long,
        excludedAccountTypes: List<Account.Type> = emptyList()
    ): List<Pair<AccountCacheData, AssetInformation>> {
        val result = mutableListOf<Pair<AccountCacheData, AssetInformation>>()
        accountCacheMap.value
            .filterNot { it.value.account.type in excludedAccountTypes }
            .forEach { (_, accountCacheData) ->
                val foundAsset = accountCacheData.assetsInformation.firstOrNull { it.assetId == assetId }
                if (foundAsset != null) {
                    result.add(Pair(accountCacheData, foundAsset))
                }
            }
        return result
    }

    fun isAccountOwnerOfAsset(publicKey: String, assetId: Long): Boolean {
        return accountCacheMap.value[publicKey]?.assetsInformation?.any { it.assetId == assetId } == true
    }

    fun getMinBalanceOfAccount(publicKey: String): BigInteger {
        return accountCacheMap.value[publicKey]?.getMinBalance()?.toBigInteger() ?: minBalancePerAssetAsBigInteger
    }

    fun getAccountName(publicKey: String) = accountCacheMap.value[publicKey]?.account?.name

    fun getAccountAssetCount(publicKey: String) = accountCacheMap.value[publicKey]?.assetsInformation?.size

    private fun isAssetVerified(assetId: Long): Boolean {
        return verifiedAssetList.any { verifiedAsset -> verifiedAsset.assetId == assetId }
    }

    fun setVerifiedAssetList(verifiedAssetList: List<VerifiedAssetDetail>) {
        this.verifiedAssetList = verifiedAssetList
    }

    fun getAuthAccount(account: Account?): Account? {
        if (account == null) {
            return null
        }
        val authAddress = accountCacheMap.value[account.address]?.authAddress
        return if (authAddress.isNullOrEmpty()) {
            account
        } else {
            accountManager.getAccount(authAddress)
        }
    }

    fun getCacheData(publicKey: String?): AccountCacheData? {
        return accountCacheMap.value[publicKey]
    }

    fun removeCachedData() {
        accountCacheMap.value = mutableMapOf()
    }
}
