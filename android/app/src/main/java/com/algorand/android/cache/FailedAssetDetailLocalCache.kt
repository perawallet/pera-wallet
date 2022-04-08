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
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FailedAssetDetailLocalCache @Inject constructor() : LocalCache<Long, Long>() {

    override suspend fun put(value: CacheResult.Success<Long>) {
        // Since this class keeps errors only, we don't need this function
    }

    override suspend fun put(key: Long, value: CacheResult.Error<Long>) {
        cacheValue(key, value)
    }

    override suspend fun put(valueList: List<CacheResult.Success<Long>>) {
        val cacheResultPairList = valueList.map { Pair(it.data, it) }
        cacheAll(cacheResultPairList)
    }

    override suspend fun putAll(keyValuePair: List<Pair<Long, CacheResult<Long>>>) {
        cacheAll(keyValuePair)
    }
}
