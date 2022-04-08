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

package com.algorand.android.utils.coremanager

import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AccountDetail
import com.algorand.android.usecase.AccountCacheStatusUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AssetFetchAndCacheUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.CacheResult
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.launchIn

class AssetCacheManager(
    private val accountCacheStatusUseCase: AccountCacheStatusUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetFetchAndCacheUseCase: AssetFetchAndCacheUseCase
) : BaseCacheManager() {

    var cacheStatus: AssetCacheStatus = AssetCacheStatus.NOT_STARTED
        private set

    private val accountCacheAndAccountCollector: suspend (
        AccountCacheStatus,
        HashMap<String, CacheResult<AccountDetail>>
    ) -> Unit = { cacheStatus, accountDetailCacheResult ->
        when {
            cacheStatus == AccountCacheStatus.DONE && accountDetailCacheResult.values.isEmpty() -> updateCacheStatus(
                AssetCacheStatus.EMPTY
            )
            cacheStatus == AccountCacheStatus.DONE && accountDetailCacheResult.values.isNotEmpty() -> startJob()
            else -> if (isCurrentJobActive) stopCurrentJob()
        }
    }

    override suspend fun initialize(coroutineScope: CoroutineScope) {
        accountCacheStatusUseCase.getAccountCacheStatusFlow()
            .combine(accountDetailUseCase.getAccountDetailCacheFlow(), accountCacheAndAccountCollector)
            .launchIn(coroutineScope)
    }

    override fun doBeforeJobStarts() {
        updateCacheStatus(AssetCacheStatus.STARTED)
    }

    override suspend fun doJob(coroutineScope: CoroutineScope) {
        val assetIdsOfAccounts = getAllAssetIdsOfAccounts()
        val filteredAssetIdLists = simpleAssetDetailUseCase.getChunkedAndFilteredAssetList(assetIdsOfAccounts)
        if (filteredAssetIdLists.isEmpty()) {
            updateCacheStatus(AssetCacheStatus.EMPTY)
            return
        }
        assetFetchAndCacheUseCase.processFilteredAssetIdList(filteredAssetIdLists, coroutineScope)
        updateCacheStatus(AssetCacheStatus.INITIALIZED)
    }

    private fun getAllAssetIdsOfAccounts(): Set<Long> {
        return accountDetailUseCase.getAccountDetailCacheFlow().value
            .values.mapNotNull { it.data?.accountInformation?.getAllAssetIds() }
            .flatten()
            .toSet()
    }

    private fun updateCacheStatus(newStatus: AssetCacheStatus) {
        if (newStatus.ordinal > cacheStatus.ordinal) {
            cacheStatus = newStatus
        }
    }

    enum class AssetCacheStatus {
        NOT_STARTED,
        STARTED,
        EMPTY,
        INITIALIZED;

        infix fun isAtLeast(status: AssetCacheStatus): Boolean {
            return ordinal >= status.ordinal
        }
    }
}
