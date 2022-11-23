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

package com.algorand.android.modules.accountblockpolling.domain.usecase

import com.algorand.android.modules.accountblockpolling.domain.repository.AccountBlockPollingRepository
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import javax.inject.Named

class UpdateLastKnownBlockUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    @Named(AccountBlockPollingRepository.INJECTION_NAME)
    private val accountBlockPollingRepository: AccountBlockPollingRepository

) {

    suspend operator fun invoke() {
        val earliestRoundOfFetchedAccounts = getEarliestRoundOfFetchedAccounts()
        accountBlockPollingRepository.updateLastKnownAccountBlockNumber(
            blockNumber = CacheResult.Success.create(earliestRoundOfFetchedAccounts)
        )
    }

    private fun getEarliestRoundOfFetchedAccounts(): Long {
        return accountDetailUseCase.getCachedAccountDetails()
            .filter { cacheResult -> cacheResult.data?.accountInformation?.createdAtRound != null }
            .minOfOrNull { it.data?.accountInformation?.lastFetchedRound ?: INITIAL_BLOCK_NUMBER }
            ?: INITIAL_BLOCK_NUMBER
    }

    companion object {
        private const val INITIAL_BLOCK_NUMBER = 0L
    }
}
