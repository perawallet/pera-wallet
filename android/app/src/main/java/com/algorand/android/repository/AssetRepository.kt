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

package com.algorand.android.repository

import com.algorand.android.cache.SimpleAssetLocalCache
import com.algorand.android.models.Asset
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetDetailResponse
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.AssetSupportRequest
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.network.IndexerApi
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.network.safeApiCall
import com.algorand.android.utils.AlgoAssetInformationProvider
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.toQueryString
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class AssetRepository @Inject constructor(
    private val indexerApi: IndexerApi,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val simpleAssetLocalCache: SimpleAssetLocalCache,
    private val algoAssetInformationProvider: AlgoAssetInformationProvider
) {
    suspend fun getAssetsMore(url: String): Result<Pagination<AssetDetailResponse>> =
        safeApiCall { requestGetAssetsMore(url) }

    private suspend fun requestGetAssetsMore(url: String) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getAssetsMore(url)
    }

    suspend fun getAssets(queryText: String, queryType: AssetQueryType): Result<Pagination<AssetDetailResponse>> =
        safeApiCall { requestGetAssets(queryText, queryType) }

    private suspend fun requestGetAssets(
        queryText: String,
        queryType: AssetQueryType
    ): Result<Pagination<AssetDetailResponse>> = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getAssets(assetQuery = queryText.takeIf { it.isNotEmpty() }, status = queryType.apiName)
    }

    suspend fun fetchAssetsById(assetIdList: List<Long>) = safeApiCall {
        requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.getAssetsByIds(assetIdList.toQueryString())
        }
    }

    suspend fun postAssetSupportRequest(assetSupportRequest: AssetSupportRequest): Result<Unit> {
        return safeApiCall { requestPostAssetSupportRequest(assetSupportRequest) }
    }

    private suspend fun requestPostAssetSupportRequest(assetSupportRequest: AssetSupportRequest) =
        requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.postAssetSupportRequest(assetSupportRequest)
        }

    suspend fun getAssetDescription(assetId: Long): Result<Asset> =
        safeApiCall { requestGetAssetDescription(assetId) }

    private suspend fun requestGetAssetDescription(assetId: Long): Result<Asset> {
        with(indexerApi.getAssetDescription(assetId)) {
            return if (isSuccessful && this.body() != null) {
                val response = body()?.asset
                if (response != null) {
                    Result.Success(response)
                } else {
                    Result.Error(
                        Exception(
                            "Api response returned empty body while trying to fetch asset description, assetId $assetId"
                        )
                    )
                }
            } else {
                Result.Error(Exception())
            }
        }
    }

    suspend fun cacheAsset(asset: CacheResult.Success<AssetDetail>) {
        simpleAssetLocalCache.put(asset)
    }

    suspend fun cacheAsset(assetId: Long, asset: CacheResult.Error<AssetDetail>) {
        simpleAssetLocalCache.put(assetId, asset)
    }

    suspend fun cacheAssets(assetList: List<CacheResult.Success<AssetDetail>>) {
        simpleAssetLocalCache.put(assetList)
    }

    suspend fun cacheAllAssets(assetKeyValuePairList: List<Pair<Long, CacheResult<AssetDetail>>>) {
        simpleAssetLocalCache.putAll(assetKeyValuePairList)
    }

    fun getAssetCacheFlow() = simpleAssetLocalCache.cacheMapFlow

    fun getCachedAssetById(assetId: Long): CacheResult<AssetDetail>? {
        return if (assetId == ALGORAND_ID) {
            algoAssetInformationProvider.getAlgoAssetInformation()
        } else {
            simpleAssetLocalCache.getOrNull(assetId)
        }
    }

    suspend fun clearAssetCache() {
        simpleAssetLocalCache.clear()
    }

    suspend fun clearAssetCache(assetId: Long) {
        simpleAssetLocalCache.remove(assetId)
    }
}
