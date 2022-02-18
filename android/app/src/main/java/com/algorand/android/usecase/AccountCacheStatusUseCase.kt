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

import com.algorand.android.core.AccountManager
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.repository.AccountRepository
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.mapLatest

class AccountCacheStatusUseCase @Inject constructor(
    private val accountManager: AccountManager,
    private val accountRepository: AccountRepository
) {

    fun getAccountCacheStatusFlow(): Flow<AccountCacheStatus> {
        return channelFlow {
            val cacheSizeFlow = accountRepository.getAccountDetailCacheFlow()
                .mapLatest { it.size }
                .distinctUntilChanged()
            accountManager.accounts.combine(cacheSizeFlow) { accounts, cachedAccountSize ->
                return@combine when {
                    cachedAccountSize < accounts.size -> AccountCacheStatus.LOADING
                    else -> AccountCacheStatus.DONE
                }
            }.collectLatest {
                send(it)
            }
        }
    }
}
