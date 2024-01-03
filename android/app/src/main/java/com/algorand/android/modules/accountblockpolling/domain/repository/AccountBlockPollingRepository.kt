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

package com.algorand.android.modules.accountblockpolling.domain.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.accountblockpolling.data.model.ShouldRefreshResponse
import com.algorand.android.utils.CacheResult

interface AccountBlockPollingRepository {

    fun clearLastKnownAccountBlockNumber()

    fun updateLastKnownAccountBlockNumber(blockNumber: CacheResult<Long>)

    fun getLastKnownAccountBlockNumber(): CacheResult<Long>?

    suspend fun getResultWhetherAccountsUpdateIsRequired(
        localAccountAddresses: List<String>,
        latestKnownRound: Long?
    ): Result<ShouldRefreshResponse>

    companion object {
        const val INJECTION_NAME = "accountBlockPollingRepositoryInjection"
    }
}
