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
import com.algorand.android.mapper.AssetDetailMapper
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.repository.AssetRepository
import com.algorand.android.usecase.AssetFetchAndCacheUseCase.Companion.MAX_ASSET_FETCH_COUNT
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.mapResult
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class SimpleAssetDetailUseCase @Inject constructor(
    private val assetRepository: AssetRepository,
    private val assetFetchAndCacheUseCase: AssetFetchAndCacheUseCase,
    private val assetDetailMapper: AssetDetailMapper
) : BaseUseCase() {

    fun isAssetCached(assetId: Long): Boolean = assetRepository.getCachedAssetById(assetId) != null

    fun getCachedAssetList() = assetRepository.getAssetCacheFlow().value

    fun getCachedAssetDetail(assetId: Long) = assetRepository.getCachedAssetById(assetId)

    fun getCachedAssetDetail(assetIdList: List<Long>): List<CacheResult<AssetDetail>> {
        return assetRepository.getAssetCacheFlow().value.filter {
            assetIdList.contains(it.key)
        }.values.toList()
    }

    suspend fun cacheAssets(assetList: List<CacheResult.Success<AssetDetail>>) {
        assetRepository.cacheAssets(assetList)
    }

    suspend fun cacheAsset(asset: CacheResult.Success<AssetDetail>) {
        assetRepository.cacheAsset(asset)
    }

    suspend fun cacheAsset(assetId: Long, asset: CacheResult.Error<AssetDetail>) {
        assetRepository.cacheAsset(assetId, asset)
    }

    suspend fun cacheAllAssets(assetKeyValuePairList: List<Pair<Long, CacheResult<AssetDetail>>>) {
        assetRepository.cacheAllAssets(assetKeyValuePairList)
    }

    fun getCachedAssetsFlow() = assetRepository.getAssetCacheFlow()

    fun areAllAssetsCached(assetIdList: Set<Long>): Boolean {
        return assetRepository.getAssetCacheFlow().value.size == assetIdList.size
    }

    suspend fun clearAssetDetailCache() {
        assetRepository.clearAssetCache()
    }

    suspend fun clearAssetDetailCache(assetId: Long) {
        assetRepository.clearAssetCache(assetId)
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

    suspend fun fetchAssetById(assetIdList: List<Long>) = flow<DataResource<List<AssetDetail>>> {
        assetRepository.fetchAssetsById(assetIdList).use(
            onSuccess = { assetDetailResponsePagination ->
                val assetDetailList = assetDetailResponsePagination.results.map { assetDetailResponse ->
                    assetDetailMapper.mapToAssetDetail(assetDetailResponse)
                }
                emit(DataResource.Success(assetDetailList))
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

    /**
     * Takes asset id list and filters them if
     *  - Asset is not cached
     *  OR
     *  - Asset is cached but expired
     * @return List that contains lists which have max "MAX_ASSET_FETCH_COUNT" items.
     */
    fun getChunkedAndFilteredAssetList(assetIdList: Set<Long>): List<List<Long>> {
        val cachedAssets = getCachedAssetList()
        val currentTime = CacheResult.createCreationTimestamp()
        val assetsNeedsToBeCached = assetIdList.filter {
            // is asset cached
            val cachedAsset = cachedAssets.getOrDefault(it, null) ?: return@filter true
            // is asset cache expired
            currentTime - (cachedAsset.creationTimestamp ?: 0) >= CACHED_ASSET_EXPIRATION_THRESHOLD
        }
        return assetsNeedsToBeCached.chunked(MAX_ASSET_FETCH_COUNT)
    }

    companion object {
        private const val CACHED_ASSET_EXPIRATION_THRESHOLD = 600_000 // 10 min
    }

    suspend fun searchAssets(queryText: String, queryType: AssetQueryType): Result<Pagination<BaseAssetDetail>> {
        return assetRepository.getAssets(queryText, queryType).map { assetDetailResponsePagination ->
            assetDetailResponsePagination.mapResult { assetDetailResponseList ->
                assetDetailResponseList.map { assetDetailMapper.mapToAssetDetail(it) }
            }
        }
    }

    suspend fun getAssetsByUrl(url: String): Result<Pagination<BaseAssetDetail>> {
        return assetRepository.getAssetsMore(url).map { assetDetailResponsePagination ->
            assetDetailResponsePagination.mapResult { assetDetailResponseList ->
                assetDetailResponseList.map { assetDetailMapper.mapToAssetDetail(it) }
            }
        }
    }
}
