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

package com.algorand.android.nft.domain.usecase

import com.algorand.android.models.SimpleCollectibleDetail
import com.algorand.android.nft.data.repository.SimpleCollectibleRepository
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import kotlinx.coroutines.flow.StateFlow

class SimpleCollectibleUseCase @Inject constructor(
    private val collectibleRepository: SimpleCollectibleRepository
) {

    fun isCollectibleCached(collectibleAssetId: Long): Boolean {
        return collectibleRepository.getCachedCollectibleById(collectibleAssetId) != null
    }

    fun getCachedCollectibleList() = collectibleRepository.getCollectiblesCacheFlow().value

    fun getCachedCollectibleListFlow(): StateFlow<HashMap<Long, CacheResult<SimpleCollectibleDetail>>> {
        return collectibleRepository.getCollectiblesCacheFlow()
    }

    fun getCachedCollectibleList(collectibleIdList: List<Long>): List<CacheResult<SimpleCollectibleDetail>> {
        return collectibleRepository.getCollectiblesCacheFlow().value.filter {
            collectibleIdList.contains(it.key)
        }.values.toList()
    }

    fun getCachedCollectibleById(nftAssetId: Long): CacheResult<SimpleCollectibleDetail>? {
        return collectibleRepository.getCachedCollectibleById(nftAssetId)
    }

    suspend fun cacheCollectibleDetail(collectible: CacheResult.Success<SimpleCollectibleDetail>) {
        collectibleRepository.cacheCollectible(collectible)
    }

    suspend fun cacheAllCollectibles(collectibles: List<Pair<Long, CacheResult<SimpleCollectibleDetail>>>) {
        collectibleRepository.cacheAllCollectibles(collectibles)
    }

    suspend fun clearCollectibleCache() {
        collectibleRepository.clearCollectibleCache()
    }
}
