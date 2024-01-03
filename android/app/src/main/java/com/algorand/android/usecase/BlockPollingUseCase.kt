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

import com.algorand.android.repository.BlockRepository
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class BlockPollingUseCase @Inject constructor(
    private val blockRepository: BlockRepository
) {

    fun cacheBlockNumber(lastBlockNumber: CacheResult<Long>) {
        blockRepository.cacheBlockNumber(lastBlockNumber)
    }

    fun getBlockNumberFlow() = blockRepository.getBlockPollingCacheFlow()

    fun getLatestCachedBlockNumber() = blockRepository.getLatestCachedBlockNumber()

    fun clearBlockCache() {
        blockRepository.clearBlockCache()
    }

    suspend fun getNextBlockAwaiting(lastBlockNumber: Long?) = flow {
        blockRepository.getWaitForBlock(lastBlockNumber ?: INITIAL_BLOCK_NUMBER).use(
            onSuccess = {
                emit(DataResource.Success(it.nextBlockNumber))
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api<Long>(exception, code))
            }
        )
    }

    companion object {
        private const val INITIAL_BLOCK_NUMBER = 0L
    }
}
