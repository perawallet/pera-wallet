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
 */

package com.algorand.android.nft.data.repository

import com.algorand.android.models.Result
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.request
import com.algorand.android.nft.data.mapper.CollectibleDetailDTOMapper
import com.algorand.android.nft.domain.model.CollectibleDetailDTO
import com.algorand.android.nft.domain.repository.CollectibleDetailRepository
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class CollectibleDetailRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val collectibleDetailDTOMapper: CollectibleDetailDTOMapper
) : CollectibleDetailRepository {

    override suspend fun getCollectibleDetail(collectibleAssetId: Long): Flow<Result<CollectibleDetailDTO>> = flow {
        request { mobileAlgorandApi.getCollectibleDetail(collectibleAssetId) }.use(
            onSuccess = { assetDetailResponse ->
                val collectibleDetail = collectibleDetailDTOMapper.mapToCollectibleDetail(assetDetailResponse)
                emit(Result.Success(collectibleDetail))
            },
            onFailed = { exception, code ->
                emit(Result.Error(exception, code))
            }
        )
    }
}
