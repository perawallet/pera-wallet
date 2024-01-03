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

package com.algorand.android.modules.collectibles.detail.base.data.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.collectibles.detail.base.data.mapper.CollectibleDetailDTOMapper
import com.algorand.android.modules.collectibles.detail.base.data.model.CollectibleDetailDTO
import com.algorand.android.modules.collectibles.detail.base.domain.repository.CollectibleDetailRepository
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler

class CollectibleDetailRepositoryImpl(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val collectibleDetailDTOMapper: CollectibleDetailDTOMapper,
    private val retrofitErrorHandler: RetrofitErrorHandler
) : CollectibleDetailRepository {

    override suspend fun getCollectibleDetail(collectibleAssetId: Long): Result<CollectibleDetailDTO> {
        return requestWithHipoErrorHandler(retrofitErrorHandler) {
            mobileAlgorandApi.getAssetDetail(collectibleAssetId)
        }.map { assetDetailResponse ->
            collectibleDetailDTOMapper.mapToCollectibleDetail(assetDetailResponse)
        }
    }
}
