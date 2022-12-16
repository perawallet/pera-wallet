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

package com.algorand.android.assetsearch.data.repository

import com.algorand.android.assetsearch.data.mapper.AssetSearchDTOMapper
import com.algorand.android.assetsearch.domain.model.AssetSearchDTO
import com.algorand.android.assetsearch.domain.repository.AssetSearchRepository
import com.algorand.android.models.AssetSearchResponse
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class AssetSearchRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val assetSearchDTOMapper: AssetSearchDTOMapper
) : AssetSearchRepository {

    override suspend fun searchAsset(
        queryText: String,
        hasCollectible: Boolean?,
        availableOnDiscoverMobile: Boolean?
    ): Result<Pagination<AssetSearchDTO>> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            val assetQuery = queryText.takeIf { it.isNotBlank() }
            mobileAlgorandApi.getAssets(
                assetQuery = assetQuery,
                hasCollectible = hasCollectible,
                availableOnDiscoverMobile = availableOnDiscoverMobile
            )
        }.map { paginationData ->
            mapToAssetSearchDTO(paginationData)
        }
    }

    override suspend fun getTrendingAssets(): Result<Pagination<AssetSearchDTO>> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.getTrendingAssets()
        }.map { listData ->
            mapToAssetSearchDTO(Pagination(null, listData))
        }
    }

    override suspend fun getAssetsByUrl(url: String): Result<Pagination<AssetSearchDTO>> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.getAssetsMore(url)
        }.map { paginationData -> mapToAssetSearchDTO(paginationData) }
    }

    private fun mapToAssetSearchDTO(paginationData: Pagination<AssetSearchResponse>): Pagination<AssetSearchDTO> {
        val assetDetailDTOResult = paginationData.results.map { assetSearchDTOMapper.mapToAssetSearchDTO(it) }
        return Pagination(paginationData.next, assetDetailDTOResult)
    }
}
