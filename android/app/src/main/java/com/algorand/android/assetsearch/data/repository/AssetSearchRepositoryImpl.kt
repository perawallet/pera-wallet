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

import com.algorand.android.assetsearch.data.mapper.AssetDetailDTOMapper
import com.algorand.android.assetsearch.domain.model.AssetDetailDTO
import com.algorand.android.assetsearch.domain.repository.AssetSearchRepository
import com.algorand.android.models.AssetDetailResponse
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class AssetSearchRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val assetDetailDTOMapper: AssetDetailDTOMapper
) : AssetSearchRepository {

    override suspend fun searchAsset(
        queryText: String,
        queryType: AssetQueryType,
        hasCollectible: Boolean?
    ): Result<Pagination<AssetDetailDTO>> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            val assetQuery = queryText.takeIf { it.isNotBlank() }
            mobileAlgorandApi.getAssets(
                assetQuery = assetQuery,
                status = queryType.apiName,
                hasCollectible = hasCollectible
            )
        }.map { paginationData -> mapToAssetDetailDTO(paginationData) }
    }

    override suspend fun getAssetsByUrl(url: String): Result<Pagination<AssetDetailDTO>> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.getAssetsMore(url)
        }.map { paginationData -> mapToAssetDetailDTO(paginationData) }
    }

    private fun mapToAssetDetailDTO(paginationData: Pagination<AssetDetailResponse>): Pagination<AssetDetailDTO> {
        val assetDetailDTOResult = paginationData.results.map { assetDetailDTOMapper.mapToAssetDetailDTO(it) }
        return Pagination(paginationData.next, assetDetailDTOResult)
    }
}
