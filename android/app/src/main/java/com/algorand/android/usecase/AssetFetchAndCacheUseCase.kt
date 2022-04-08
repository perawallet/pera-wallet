/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.AssetDetailMapper
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetDetailResponse
import com.algorand.android.models.SimpleCollectibleDetail
import com.algorand.android.nft.data.repository.SimpleCollectibleRepository
import com.algorand.android.nft.domain.mapper.SimpleCollectibleDetailMapper
import com.algorand.android.repository.AssetRepository
import com.algorand.android.repository.FailedAssetRepository
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.isAssetCollectible
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll

class AssetFetchAndCacheUseCase @Inject constructor(
    private val assetRepository: AssetRepository,
    private val collectibleRepository: SimpleCollectibleRepository,
    private val failedAssetRepository: FailedAssetRepository,
    private val assetDetailMapper: AssetDetailMapper,
    private val simpleCollectibleDetailMapper: SimpleCollectibleDetailMapper
) : BaseUseCase() {

    suspend fun processFilteredAssetIdList(assetIdLists: List<List<Long>>, coroutineScope: CoroutineScope) {
        val assetCacheResultList = assetIdLists.map { assetIdList ->
            coroutineScope.async { fetchAndCacheAssets(assetIdList) }
        }.awaitAll()
        cacheFetchResult(assetCacheResultList)
    }

    private suspend fun fetchAndCacheAssets(assetIdList: List<Long>): AssetCacheResultData {
        lateinit var result: AssetCacheResultData
        assetRepository.fetchAssetsById(assetIdList).use(
            onSuccess = {
                result = onGetAssetsSuccess(it.results, assetIdList)
            },
            onFailed = { exception, code ->
                result = onGetAssetsFailed(exception, code, assetIdList)
            }
        )
        return result
    }

    private suspend fun onGetAssetsSuccess(
        assetDetailResponseList: List<AssetDetailResponse>,
        assetIdList: List<Long>
    ): AssetCacheResultData {
        assetIdList.forEach { failedAssetRepository.removeFailedAssetCache(it) }
        filterNotReturnedAssets(assetDetailResponseList, assetIdList)
        val assetCacheList = mutableListOf<Pair<Long, CacheResult<AssetDetail>>>()
        val collectibleCacheList = mutableListOf<Pair<Long, CacheResult<SimpleCollectibleDetail>>>()

        // TODO Use AssetDetailDTO instead of response
        assetDetailResponseList.forEach { assetDetailResponse ->
            if (isAssetCollectible(assetDetailResponse)) {
                val result = simpleCollectibleDetailMapper.mapToCollectibleDetail(assetDetailResponse)
                collectibleCacheList.add(assetDetailResponse.assetId to CacheResult.Success.create(result))
            } else {
                val result = assetDetailMapper.mapToAssetDetail(assetDetailResponse)
                assetCacheList.add(assetDetailResponse.assetId to CacheResult.Success.create(result))
            }
        }
        return AssetCacheResultData(assetCacheList, collectibleCacheList)
    }

    /**
     * This function clears not returned assets (Deleted asset case) if they are cached as Error.
     * Case example:
     * Indexer returns asset as "not deleted" which is actually deleted.
     * We fetch this asset and we get error (i.e internet connection) then we cache this asset as Error.
     * When we get a success from API, this function checks if is there any deleted assets in the success result.
     * P.S. Deleted assets are not included in Success result.
     */
    private suspend fun filterNotReturnedAssets(
        assetDetailResponseList: List<AssetDetailResponse>,
        assetIdList: List<Long>
    ) {
        val returnedAssetIdList = assetDetailResponseList.map { it.assetId }
        val notReturnedAssets = assetIdList.filterNot { assetId ->
            returnedAssetIdList.contains(assetId)
        }
        notReturnedAssets.forEach { assetId ->
            assetRepository.clearAssetCache(assetId)
        }
    }

    private fun onGetAssetsFailed(
        exception: Exception?,
        code: Int?,
        assetIdList: List<Long>
    ): AssetCacheResultData {
        val failedAssetList = mutableListOf<Pair<Long, CacheResult.Error<AssetDetail>>>()
        val failedCollectibleList = mutableListOf<Pair<Long, CacheResult.Error<SimpleCollectibleDetail>>>()
        val failedAssetIdList = mutableListOf<Pair<Long, CacheResult.Error<Long>>>()

        assetIdList.forEach { assetId ->
            val cachedCollectible = collectibleRepository.getCachedCollectibleById(assetId)
            if (cachedCollectible != null) {
                failedCollectibleList.add(assetId to CacheResult.Error.create(exception, code, cachedCollectible))
                return@forEach
            }

            val cachedAsset = assetRepository.getCachedAssetById(assetId)
            if (cachedAsset != null) {
                failedAssetList.add(assetId to CacheResult.Error.create(exception, code, cachedAsset))
                return@forEach
            }
            failedAssetIdList.add(assetId to CacheResult.Error.create(exception, code))
        }
        return AssetCacheResultData(failedAssetList, failedCollectibleList, failedAssetIdList)
    }

    private suspend fun cacheFetchResult(assetCacheResultList: List<AssetCacheResultData>) {
        val assetResult = mutableListOf<Pair<Long, CacheResult<AssetDetail>>>()
        val collectibleResult = mutableListOf<Pair<Long, CacheResult<SimpleCollectibleDetail>>>()
        val failedAssetIdList = mutableListOf<Pair<Long, CacheResult.Error<Long>>>()
        assetCacheResultList.forEach {
            assetResult.addAll(it.assetDetailList.orEmpty())
            collectibleResult.addAll(it.collectibleDetailList.orEmpty())
            failedAssetIdList.addAll(it.failedAssetList.orEmpty())
        }
        assetRepository.cacheAllAssets(assetResult)
        collectibleRepository.cacheAllCollectibles(collectibleResult)
        failedAssetRepository.cacheAllFailedAssets(failedAssetIdList)
    }

    private data class AssetCacheResultData(
        val assetDetailList: List<Pair<Long, CacheResult<AssetDetail>>>? = null,
        val collectibleDetailList: List<Pair<Long, CacheResult<SimpleCollectibleDetail>>>? = null,
        val failedAssetList: List<Pair<Long, CacheResult.Error<Long>>>? = null
    )

    companion object {
        const val MAX_ASSET_FETCH_COUNT = 100
    }
}
