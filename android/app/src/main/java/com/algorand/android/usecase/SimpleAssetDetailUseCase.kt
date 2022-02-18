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

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.repository.AssetRepository
import com.algorand.android.usecase.AssetFetchAndCacheUseCase.Companion.MAX_ASSET_FETCH_COUNT
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class SimpleAssetDetailUseCase @Inject constructor(
    private val assetRepository: AssetRepository,
    private val assetFetchAndCacheUseCase: AssetFetchAndCacheUseCase
) : BaseUseCase() {

    fun isAssetCached(assetId: Long): Boolean = assetRepository.getCachedAssetById(assetId) != null

    fun getCachedAssetList() = assetRepository.getAssetCacheFlow().value

    fun getCachedAssetDetail(assetId: Long) = assetRepository.getCachedAssetById(assetId)

    fun getCachedAssetDetail(assetIdList: List<Long>): List<CacheResult<AssetQueryItem>> {
        return assetRepository.getAssetCacheFlow().value.filter {
            assetIdList.contains(it.key)
        }.values.toList()
    }

    suspend fun cacheAssets(assetList: List<CacheResult.Success<AssetQueryItem>>) {
        assetRepository.cacheAssets(assetList)
    }

    suspend fun cacheAsset(asset: CacheResult.Success<AssetQueryItem>) {
        assetRepository.cacheAsset(asset)
    }

    suspend fun cacheAsset(assetId: Long, asset: CacheResult.Error<AssetQueryItem>) {
        assetRepository.cacheAsset(assetId, asset)
    }

    fun getCachedAssetsFlow() = assetRepository.getAssetCacheFlow()

    fun areAllAssetsCached(assetIdList: Set<Long>): Boolean {
        return assetRepository.getAssetCacheFlow().value.size == assetIdList.size
    }

    suspend fun clearAssetDetailCache() {
        assetRepository.clearAssetCache()
    }

    suspend fun fetchAndCacheAsset(assetId: Long) {
        fetchAssetById(listOf(assetId)).collect {
            it.useSuspended(
                onSuccess = { assetResultList ->
                    val asset = assetResultList.firstOrNull() ?: return@useSuspended
                    cacheAsset(CacheResult.Success.create(asset))
                },
                onFailed = {
                    cacheAsset(assetId, CacheResult.Error.create(it.exception, it.code))
                }
            )
        }
    }

    suspend fun fetchAssetById(assetIdList: List<Long>) = flow<DataResource<List<AssetQueryItem>>> {
        assetRepository.fetchAssetsById(assetIdList).use(
            onSuccess = {
                emit(DataResource.Success(it.results))
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api(exception, code))
            }
        )
    }

    suspend fun cacheIfThereIsNonCachedAsset(assetIdList: Set<Long>, coroutineScope: CoroutineScope) {
        val filteredAssetIdLists = getChunkedAndFilteredAssetList(assetIdList)
        if (filteredAssetIdLists.isEmpty()) return
        assetFetchAndCacheUseCase.processFilteredAssetIdList(filteredAssetIdLists, coroutineScope)
    }

    fun getChunkedAndFilteredAssetList(assetIdList: Set<Long>): List<List<Long>> {
        val cachedAssetIdList = getCachedAssetList().map { it.key }
        val notCachedAssetIdList = assetIdList.filterNot { assetId -> cachedAssetIdList.contains(assetId) }
        return notCachedAssetIdList.chunked(MAX_ASSET_FETCH_COUNT)
    }
}
