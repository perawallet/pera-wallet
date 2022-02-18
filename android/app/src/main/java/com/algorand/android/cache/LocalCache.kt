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

package com.algorand.android.cache

import com.algorand.android.utils.CacheResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.withContext

/**
 * Base class to handle caching multiple value. Keeps values in map as Key-Value pairs.
 * Wraps value with CacheResult which keeps status of the cached value; Success or Error
 */
abstract class LocalCache<KEY, VALUE> {

    val cacheMapFlow: StateFlow<HashMap<KEY, CacheResult<VALUE>>>
        get() = _cacheMapFlow
    private val _cacheMapFlow = MutableStateFlow<HashMap<KEY, CacheResult<VALUE>>>(HashMap())

    abstract suspend fun put(value: CacheResult.Success<VALUE>)

    abstract suspend fun put(key: KEY, value: CacheResult.Error<VALUE>)

    abstract suspend fun put(valueList: List<CacheResult.Success<VALUE>>)

    open suspend fun put(key: KEY, value: CacheResult<VALUE>) {
        cacheValue(key, value)
    }

    open suspend fun putAll(keyValuePair: List<Pair<KEY, CacheResult<VALUE>>>) {
        cacheAll(keyValuePair)
    }

    fun getOrNull(key: KEY): CacheResult<VALUE>? = cacheMapFlow.value.getOrElse(key) { null }

    suspend fun remove(key: KEY): CacheResult<VALUE>? {
        var removedItem: CacheResult<VALUE>? = null
        updateCacheMap { cacheMap ->
            removedItem = cacheMap.remove(key)
        }
        return removedItem
    }

    suspend fun clear() {
        updateCacheMap { cacheMap -> cacheMap.clear() }
    }

    protected suspend fun cacheValue(key: KEY, value: CacheResult<VALUE>) {
        updateCacheMap { cacheMap -> cacheMap[key] = value }
    }

    protected suspend fun cacheAll(keyValuePairList: List<Pair<KEY, CacheResult<VALUE>>>) {
        updateCacheMap { cacheMap ->
            cacheMap.putAll(keyValuePairList.map { Pair(it.first, it.second) })
        }
    }

    private suspend fun updateCacheMap(action: (MutableMap<KEY, CacheResult<VALUE>>) -> Unit) {
        withContext(Dispatchers.Default) {
            val newMap = _cacheMapFlow.value.toMutableMap()
            action(newMap)
            _cacheMapFlow.value = newMap as HashMap<KEY, CacheResult<VALUE>>
        }
    }
}
