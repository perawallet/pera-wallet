/*
 * Copyright 2019 Algorand, Inc.
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

import com.algorand.android.models.Asset
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.AssetSupportRequest
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.models.VerifiedAssetDetail
import com.algorand.android.network.IndexerApi
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.network.safeApiCall
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class AssetRepository @Inject constructor(
    private val indexerApi: IndexerApi,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler
) {
    suspend fun getAssetsMore(url: String): Result<Pagination<AssetQueryItem>> =
        safeApiCall { requestGetAssetsMore(url) }

    private suspend fun requestGetAssetsMore(url: String) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getAssetsMore(url)
    }

    suspend fun getAssets(queryText: String, queryType: AssetQueryType): Result<Pagination<AssetQueryItem>> =
        safeApiCall { requestGetAssets(queryText, queryType) }

    private suspend fun requestGetAssets(
        queryText: String,
        queryType: AssetQueryType
    ): Result<Pagination<AssetQueryItem>> = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getAssets(assetQuery = queryText.takeIf { it.isNotEmpty() }, status = queryType.apiName)
    }

    suspend fun postAssetSupportRequest(assetSupportRequest: AssetSupportRequest): Result<Unit> {
        return safeApiCall { requestPostAssetSupportRequest(assetSupportRequest) }
    }

    private suspend fun requestPostAssetSupportRequest(assetSupportRequest: AssetSupportRequest) =
        requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.postAssetSupportRequest(assetSupportRequest)
        }

    suspend fun getVerifiedAssetList(): Result<Pagination<VerifiedAssetDetail>> =
        safeApiCall { requestGetVerifiedAssetList() }

    private suspend fun requestGetVerifiedAssetList() = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getVerifiedAssets()
    }

    suspend fun getAssetDescription(assetId: Long): Result<Asset> =
        safeApiCall { requestGetAssetDescription(assetId) }

    private suspend fun requestGetAssetDescription(assetId: Long): Result<Asset> {
        with(indexerApi.getAssetDescription(assetId)) {
            return if (isSuccessful && body() != null) {
                val response = body() as Asset
                Result.Success(response)
            } else {
                Result.Error(Exception())
            }
        }
    }
}
