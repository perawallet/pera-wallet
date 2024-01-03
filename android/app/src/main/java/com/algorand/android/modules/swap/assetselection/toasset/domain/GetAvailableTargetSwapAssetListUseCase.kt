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

package com.algorand.android.modules.swap.assetselection.toasset.domain

import com.algorand.android.modules.swap.assetselection.toasset.domain.mapper.AvailableSwapAssetMapper
import com.algorand.android.modules.swap.assetselection.toasset.domain.model.AvailableSwapAsset
import com.algorand.android.modules.swap.assetselection.toasset.domain.model.AvailableSwapAssetDTO
import com.algorand.android.modules.swap.assetselection.toasset.domain.repository.AvailableTargetSwapAssetsRepository
import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForRequest
import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForResponse
import com.algorand.android.utils.DataResource
import java.math.BigDecimal
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

class GetAvailableTargetSwapAssetListUseCase @Inject constructor(
    @Named(AvailableTargetSwapAssetsRepository.INJECTION_NAME)
    private val availableTargetSwapAssetsRepository: AvailableTargetSwapAssetsRepository,
    private val availableSwapAssetMapper: AvailableSwapAssetMapper
) {

    suspend fun getAvailableTargetSwapAssetList(
        assetId: Long,
        query: String?
    ): Flow<DataResource<List<AvailableSwapAsset>>> = flow {
        emit(DataResource.Loading())
        val safeAssetId = getSafeAssetIdForRequest(assetId)
        availableTargetSwapAssetsRepository.getAvailableTargetSwapAssets(safeAssetId, query).map {
            it.use(
                onSuccess = { availableSwapAssetDTOList ->
                    val availableSwapAssetList = createAvailableSwapAssetList(availableSwapAssetDTOList)
                    emit(DataResource.Success(availableSwapAssetList))
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api<List<AvailableSwapAsset>>(exception, code))
                }
            )
        }.collect()
    }

    private fun createAvailableSwapAssetList(
        availableSwapAssetDTOList: List<AvailableSwapAssetDTO>
    ): List<AvailableSwapAsset> {
        return availableSwapAssetDTOList.mapNotNull { availableSwapAssetDTO ->
            val safeAssetId = getSafeAssetIdForResponse(availableSwapAssetDTO.assetId)
            availableSwapAssetMapper.mapToAvailableSwapAsset(
                assetId = safeAssetId ?: return@mapNotNull null,
                availableSwapAssetDTO = availableSwapAssetDTO,
                usdValue = availableSwapAssetDTO.usdValue?.toBigDecimalOrNull() ?: BigDecimal.ZERO
            )
        }
    }
}
