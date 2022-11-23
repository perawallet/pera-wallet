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

package com.algorand.android.modules.accountblockpolling.data.repository

import com.algorand.android.modules.accountblockpolling.data.mapper.ShouldRefreshRequestBodyMapper
import com.algorand.android.models.Result
import com.algorand.android.modules.accountblockpolling.data.model.ShouldRefreshResponse
import com.algorand.android.modules.accountblockpolling.data.local.AccountBlockPollingSingleLocalCache
import com.algorand.android.modules.accountblockpolling.domain.repository.AccountBlockPollingRepository
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.utils.CacheResult
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler

class AccountBlockPollingRepositoryImpl(
    private val accountBlockPollingSingleLocalCache: AccountBlockPollingSingleLocalCache,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val retrofitErrorHandler: RetrofitErrorHandler,
    private val shouldRefreshRequestBodyMapper: ShouldRefreshRequestBodyMapper,
) : AccountBlockPollingRepository {

    override fun clearLastKnownAccountBlockNumber() {
        accountBlockPollingSingleLocalCache.clear()
    }

    override fun updateLastKnownAccountBlockNumber(blockNumber: CacheResult<Long>) {
        accountBlockPollingSingleLocalCache.put(blockNumber)
    }

    override fun getLastKnownAccountBlockNumber(): CacheResult<Long>? {
        return accountBlockPollingSingleLocalCache.getOrNull()
    }

    override suspend fun getResultWhetherAccountsUpdateIsRequired(
        localAccountAddresses: List<String>,
        latestKnownRound: Long?
    ): Result<ShouldRefreshResponse> {
        val shouldRefreshAccountInformationRequestBody = shouldRefreshRequestBodyMapper.mapToShouldRefreshRequestBody(
            accountAddresses = localAccountAddresses,
            lastKnownRound = latestKnownRound
        )
        return requestWithHipoErrorHandler(retrofitErrorHandler) {
            mobileAlgorandApi.shouldRefresh(shouldRefreshAccountInformationRequestBody)
        }
    }
}
