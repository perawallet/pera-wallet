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

package com.algorand.android.modules.transaction.detail.data.cache

import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import java.util.Stack
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.withContext

@Singleton
class InnerTransactionLocalStackCache @Inject constructor() {

    private val _innerTransactionCacheStackFlow = MutableStateFlow<Stack<List<BaseTransactionDetail>>>(Stack())

    suspend fun put(value: List<BaseTransactionDetail>) {
        withContext(Dispatchers.Default) {
            val newStack = _innerTransactionCacheStackFlow.value
            newStack.add(value)
            _innerTransactionCacheStackFlow.value = newStack
        }
    }

    suspend fun pop() {
        withContext(Dispatchers.Default) {
            val newStack = _innerTransactionCacheStackFlow.value
            newStack.pop()
            _innerTransactionCacheStackFlow.value = newStack
        }
    }

    suspend fun peek(): List<BaseTransactionDetail>? {
        var latestItem: List<BaseTransactionDetail>? = null
        withContext(Dispatchers.Default) {
            val newStack = _innerTransactionCacheStackFlow.value
            latestItem = newStack.peek()
            _innerTransactionCacheStackFlow.value = newStack
        }
        return latestItem
    }

    suspend fun clear() {
        withContext(Dispatchers.Default) {
            val newStack = _innerTransactionCacheStackFlow.value
            newStack.clear()
            _innerTransactionCacheStackFlow.value = newStack
        }
    }
}
