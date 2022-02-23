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
import com.algorand.android.usecase.BlockPollingUseCase
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest

/**
 * Helper class to manage block polling continuously.
 * Should be provided by Hilt as Singleton
 */
class BlockPollingManager(
    private val blockPollingUseCase: BlockPollingUseCase,
    private val accountManager: AccountManager
) : BaseCacheManager() {

    override suspend fun initialize(coroutineScope: CoroutineScope) {
        accountManager.accounts.collectLatest {
            if (it.isNotEmpty()) startJob() else stopCurrentJob()
        }
    }

    override fun doBeforeJobStarts() {
        stopCurrentJob()
    }

    override suspend fun doJob(coroutineScope: CoroutineScope) {
        blockPollingUseCase.getBlockNumberFlow().collectLatest {
            when (it) {
                null, is CacheResult.Success -> fetchNextBlockAwaiting(it)
                is CacheResult.Error -> {
                    delay(NEXT_BLOCK_DELAY_AFTER_ERROR)
                    fetchNextBlockAwaiting(it)
                }
            }
        }
    }

    override fun stopCurrentJob(cause: CancellationException?) {
        super.stopCurrentJob(cause)
        blockPollingUseCase.clearBlockCache()
    }

    private suspend fun fetchNextBlockAwaiting(cacheResult: CacheResult<Long>?) {
        blockPollingUseCase.getNextBlockAwaiting(cacheResult?.data).collect { dataResource ->
            dataResource.useSuspended(
                onSuccess = ::onBlockDataResourceSuccess,
                onFailed = ::onBlockDataResourceFailed
            )
        }
    }

    private suspend fun onBlockDataResourceSuccess(blockNumber: Long?) {
        with(blockPollingUseCase) {
            if (blockNumber == null) {
                getNextBlockAwaiting(null)
            } else {
                cacheBlockNumber(CacheResult.Success.create(blockNumber))
            }
        }
    }

    private fun onBlockDataResourceFailed(errorDataResource: DataResource.Error<out Long?>) {
        with(blockPollingUseCase) {
            if (errorDataResource.exception is CancellationException) {
                clearBlockCache()
            } else {
                cacheBlockNumber(CacheResult.Error.create(errorDataResource.exception, errorDataResource.code))
            }
        }
    }

    companion object {
        private const val NEXT_BLOCK_DELAY_AFTER_ERROR = 2500L
    }
}
