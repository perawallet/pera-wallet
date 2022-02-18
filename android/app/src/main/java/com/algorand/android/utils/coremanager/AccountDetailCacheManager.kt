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

import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.BlockPollingUseCase
import com.algorand.android.utils.AccountDetailUpdateHelper
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.launchIn

class AccountDetailCacheManager(
    private val blockPollingUseCase: BlockPollingUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountManager: AccountManager,
    private val accountDetailUpdateHelper: AccountDetailUpdateHelper
) : BaseManager() {

    private var accountBlockCollector: suspend (CacheResult<Long>?, List<Account>) -> Unit = { blockCache, accounts ->
        onAccountAndBlockCacheUpdate(blockCache, accounts)
    }

    override suspend fun initialize(coroutineScope: CoroutineScope) {
        blockPollingUseCase.getBlockNumberFlow()
            .combine(accountManager.accounts, accountBlockCollector)
            .launchIn(coroutineScope)
    }

    private suspend fun onAccountAndBlockCacheUpdate(blockCache: CacheResult<Long>?, accounts: List<Account>) {
        when {
            blockCache == null -> accountDetailUseCase.clearAccountDetailCache()
            accounts.isEmpty() -> stopCurrentJob()
            accounts.isNotEmpty() -> startJob()
        }
    }

    override suspend fun doJob(coroutineScope: CoroutineScope) {
        val accountCacheResultList = accountManager.accounts.value.map { account ->
            coroutineScope.async {
                getAccountCacheResult(account)
            }
        }.awaitAll()
        accountDetailUseCase.cacheAccountDetails(accountCacheResultList)
    }

    private suspend fun getAccountCacheResult(account: Account): Pair<String, CacheResult<AccountDetail>> {
        lateinit var accountCacheResult: Pair<String, CacheResult<AccountDetail>>
        accountDetailUseCase.fetchAccountDetail(account).collect { dataResource ->
            dataResource.useSuspended(
                onSuccess = { accountDetail ->
                    accountCacheResult = onFetchAccountDetailSuccess(accountDetail)
                },
                onFailed = {
                    accountCacheResult = onFetchAccountDetailFailed(it, account.address)
                }
            )
        }
        return accountCacheResult
    }

    private suspend fun onFetchAccountDetailSuccess(
        accountDetail: AccountDetail
    ): Pair<String, CacheResult.Success<AccountDetail>> {
        val updatedAccountDetail = accountDetailUpdateHelper.getUpdatedAccountDetail(accountDetail)
        val cacheResult = CacheResult.Success.create(updatedAccountDetail)
        return accountDetail.account.address to cacheResult
    }

    private fun onFetchAccountDetailFailed(
        error: DataResource.Error<AccountDetail>,
        accountPublicKey: String
    ): Pair<String, CacheResult.Error<AccountDetail>> {
        val previousCachedAccount = accountDetailUseCase.getCachedAccountDetail(accountPublicKey)
        val cacheResult = CacheResult.Error.create(error.exception, error.code, previousCachedAccount)
        return accountPublicKey to cacheResult
    }
}
