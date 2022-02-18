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
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.repository.AssetRepository
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll

class AssetFetchAndCacheUseCase @Inject constructor(
    private val assetRepository: AssetRepository
) : BaseUseCase() {

    suspend fun processFilteredAssetIdList(assetIdLists: List<List<Long>>, coroutineScope: CoroutineScope) {
        val assetCacheResultList = assetIdLists.map { assetIdList ->
            coroutineScope.async { fetchAndCacheAssets(assetIdList) }
        }.awaitAll().flatten()
        assetRepository.cacheAllAssets(assetCacheResultList)
    }

    private suspend fun fetchAndCacheAssets(assetIdList: List<Long>): List<Pair<Long, CacheResult<AssetQueryItem>>> {
        lateinit var result: List<Pair<Long, CacheResult<AssetQueryItem>>>
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
        simpleAssetDetailList: List<AssetQueryItem>,
        assetIdList: List<Long>
    ): List<Pair<Long, CacheResult.Success<AssetQueryItem>>> {
        filterNotReturnedAssets(simpleAssetDetailList, assetIdList)
        return simpleAssetDetailList.map { assetQueryItem ->
            assetQueryItem.assetId to CacheResult.Success.create(assetQueryItem)
        }
    }

    /**
     * This function clears not returned assets (Deleted asset case) if they are cached as Error.
     * Case example:
     * Indexer returns asset as "not deleted" which is actually deleted.
     * We fetch this asset and we get error (i.e internet connection) then we cache this asset as Error.
     * When we get a success from API, this function checks if is there any deleted assets in the success result.
     * P.S. Deleted assets are not included in Success result.
     */
    private suspend fun filterNotReturnedAssets(simpleAssetDetailList: List<AssetQueryItem>, assetIdList: List<Long>) {
        val returnedAssetIdList = simpleAssetDetailList.map { it.assetId }
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
    ): List<Pair<Long, CacheResult.Error<AssetQueryItem>>> {
        return assetIdList.map { assetId ->
            val previousCachedAsset = assetRepository.getCachedAssetById(assetId)
            assetId to CacheResult.Error.create(exception, code, previousCachedAsset)
        }
    }

    companion object {
        const val MAX_ASSET_FETCH_COUNT = 100
    }
}
