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

import com.algorand.android.models.Result
import com.algorand.android.repository.TransactionsRepository
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class BlockPollingManager(
    private val externalScope: CoroutineScope,
    private val transactionsRepository: TransactionsRepository
) {

    val lastBlockNumberSharedFlow = MutableSharedFlow<Long?>(1)
    val blockConnectionStableFlow = MutableStateFlow(true)

    var currentPollJob: Job? = null

    fun start() {
        if (currentPollJob?.isActive == true) {
            stop()
        }

        currentPollJob = externalScope.launch {
            while (isActive) {
                val lastBlockNumber = lastBlockNumberSharedFlow.replayCache.lastOrNull() ?: 0
                when (val response = transactionsRepository.getWaitForBlock(lastBlockNumber)) {
                    is Result.Success -> {
                        lastBlockNumberSharedFlow.emit(response.data.nextBlockNumber)
                        blockConnectionStableFlow.value = true
                    }
                    is Result.Error -> {
                        if (response.exception.cause is CancellationException) {
                            return@launch
                        } else {
                            blockConnectionStableFlow.value = false
                            lastBlockNumberSharedFlow.emit(null)
                            delay(NEXT_BLOCK_DELAY_AFTER_ERROR)
                        }
                    }
                }
            }
        }
    }

    fun stop() {
        externalScope.launch {
            currentPollJob?.cancelAndJoin()
            lastBlockNumberSharedFlow.emit(null)
        }
    }

    companion object {
        private const val NEXT_BLOCK_DELAY_AFTER_ERROR = 2500L
    }
}
