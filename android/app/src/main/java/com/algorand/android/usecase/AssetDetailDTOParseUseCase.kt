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

package com.algorand.android.usecase

import com.algorand.android.assetsearch.domain.model.AssetDetailDTO
import com.algorand.android.mapper.AssetDetailMapper
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.nft.domain.mapper.SimpleCollectibleDetailMapper
import com.algorand.android.nft.domain.model.BaseSimpleCollectible
import com.algorand.android.nft.domain.model.CollectibleMediaType
import javax.inject.Inject

class AssetDetailDTOParseUseCase @Inject constructor(
    private val assetDetailMapper: AssetDetailMapper,
    private val simpleCollectibleDetailMapper: SimpleCollectibleDetailMapper
) {

    fun parseAssetDetail(assetDetailDTO: AssetDetailDTO): BaseAssetDetail {
        return if (assetDetailDTO.collectible != null) {
            parseCollectible(assetDetailDTO)
        } else {
            assetDetailMapper.mapToAssetDetail(assetDetailDTO)
        }
    }

    private fun parseCollectible(
        assetDetailDTO: AssetDetailDTO,
    ): BaseSimpleCollectible {
        return with(simpleCollectibleDetailMapper) {
            when (assetDetailDTO.collectible?.mediaType) {
                CollectibleMediaType.IMAGE -> mapToImageSimpleCollectibleDetail(assetDetailDTO)
                CollectibleMediaType.VIDEO -> mapToVideoSimpleCollectibleDetail(assetDetailDTO)
                CollectibleMediaType.MIXED -> mapToMixedSimpleCollectibleDetail(assetDetailDTO)
                CollectibleMediaType.NOT_SUPPORTED -> mapToNotSupportedSimpleCollectibleDetail(assetDetailDTO)
                null -> mapToNotSupportedSimpleCollectibleDetail(assetDetailDTO)
            }
        }
    }
}
