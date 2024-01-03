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
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/**
 * Base class to handle caching single value.
 * Wraps value CacheResult which keeps status of the cached value; Success or Error
 */
open class SingleLocalCache<T> {

    val cacheFlow: StateFlow<CacheResult<T>?>
        get() = _cacheFlow
    private val _cacheFlow = MutableStateFlow<CacheResult<T>?>(null)

    fun getOrNull(): CacheResult<T>? = cacheFlow.value

    fun remove(): CacheResult<T>? {
        return _cacheFlow.value.also {
            clear()
        }
    }

    fun clear() {
        _cacheFlow.value = null
    }

    fun put(value: CacheResult<T>) {
        _cacheFlow.value = value
    }
}
