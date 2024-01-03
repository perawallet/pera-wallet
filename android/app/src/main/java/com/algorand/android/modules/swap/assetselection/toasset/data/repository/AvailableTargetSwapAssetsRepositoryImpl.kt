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

package com.algorand.android.modules.swap.assetselection.toasset.data.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.swap.assetselection.toasset.data.mapper.AvailableSwapAssetDTOMapper
import com.algorand.android.modules.swap.assetselection.toasset.data.model.SwapQuoteProviderResponse
import com.algorand.android.modules.swap.assetselection.toasset.domain.model.AvailableSwapAssetDTO
import com.algorand.android.modules.swap.assetselection.toasset.domain.repository.AvailableTargetSwapAssetsRepository
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.utils.toCsvString
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class AvailableTargetSwapAssetsRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val availableSwapAssetDTOMapper: AvailableSwapAssetDTOMapper,
    private val hipoErrorHandler: RetrofitErrorHandler
) : AvailableTargetSwapAssetsRepository {

    override suspend fun getAvailableTargetSwapAssets(
        assetId: Long,
        query: String?
    ): Flow<Result<List<AvailableSwapAssetDTO>>> = flow {
        val providersQuery = SwapQuoteProviderResponse.getValues().mapNotNull { it.value }.toCsvString()
        val result = requestWithHipoErrorHandler(hipoErrorHandler) {
            mobileAlgorandApi.getAvailableSwapAssetList(assetId, providersQuery, query)
        }.map { availableSwapAssetListResponse ->
            availableSwapAssetListResponse.results?.map { availableSwapAsset ->
                availableSwapAssetDTOMapper.mapToAvailableSwapAssetDTO(availableSwapAsset)
            }.orEmpty()
        }
        emit(result)
    }
}
