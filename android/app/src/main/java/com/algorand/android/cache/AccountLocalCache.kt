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

import com.algorand.android.models.AccountDetail
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AccountLocalCache @Inject constructor() : LocalCache<String, AccountDetail>() {

    override suspend fun put(value: CacheResult.Success<AccountDetail>) {
        val key = value.data.account.address
        cacheValue(key, value)
    }

    override suspend fun put(key: String, value: CacheResult.Error<AccountDetail>) {
        cacheValue(key, value)
    }

    override suspend fun put(valueList: List<CacheResult.Success<AccountDetail>>) {
        val cacheResultPairList = valueList.map {
            val key = it.data.account.address
            Pair(key, it)
        }
        cacheAll(cacheResultPairList)
    }
}
