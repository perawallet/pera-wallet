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

package com.algorand.android.nft.domain.mapper

import com.algorand.android.assetsearch.domain.model.AssetDetailDTO
import com.algorand.android.models.AssetDetailResponse
import com.algorand.android.models.SimpleCollectibleDetail
import com.algorand.android.nft.domain.model.BaseSimpleCollectible
import javax.inject.Inject

class SimpleCollectibleDetailMapper @Inject constructor(
    private val simpleCollectibleMapper: SimpleCollectibleMapper
) {

    fun mapToCollectibleDetail(assetDetailResponse: AssetDetailResponse): SimpleCollectibleDetail {
        return SimpleCollectibleDetail(
            assetId = assetDetailResponse.assetId,
            fullName = assetDetailResponse.fullName,
            shortName = assetDetailResponse.shortName,
            isVerified = assetDetailResponse.isVerified,
            fractionDecimals = assetDetailResponse.fractionDecimals,
            usdValue = assetDetailResponse.usdValue,
            assetCreator = assetDetailResponse.assetCreator,
            collectible = simpleCollectibleMapper.mapToSimpleCollectible(assetDetailResponse.collectible)!! // TODO
        )
    }

    fun mapToImageSimpleCollectibleDetail(
        assetDetailDTO: AssetDetailDTO
    ): BaseSimpleCollectible.ImageSimpleCollectibleDetail {
        return BaseSimpleCollectible.ImageSimpleCollectibleDetail(
            assetId = assetDetailDTO.assetId,
            fullName = assetDetailDTO.fullName,
            shortName = assetDetailDTO.shortName,
            isVerified = assetDetailDTO.isVerified,
            fractionDecimals = assetDetailDTO.fractionDecimals,
            usdValue = assetDetailDTO.usdValue,
            assetCreator = assetDetailDTO.assetCreator,
            title = assetDetailDTO.collectible?.title,
            collectionName = assetDetailDTO.collectible?.collectionName,
            prismUrl = assetDetailDTO.collectible?.primaryImageUrl
        )
    }

    fun mapToVideoSimpleCollectibleDetail(
        assetDetailDTO: AssetDetailDTO
    ): BaseSimpleCollectible.VideoSimpleCollectibleDetail {
        return BaseSimpleCollectible.VideoSimpleCollectibleDetail(
            assetId = assetDetailDTO.assetId,
            fullName = assetDetailDTO.fullName,
            shortName = assetDetailDTO.shortName,
            isVerified = assetDetailDTO.isVerified,
            fractionDecimals = assetDetailDTO.fractionDecimals,
            usdValue = assetDetailDTO.usdValue,
            assetCreator = assetDetailDTO.assetCreator,
            title = assetDetailDTO.collectible?.title,
            collectionName = assetDetailDTO.collectible?.collectionName,
            thumbnailPrismUrl = assetDetailDTO.collectible?.primaryImageUrl
        )
    }

    fun mapToMixedSimpleCollectibleDetail(
        assetDetailDTO: AssetDetailDTO
    ): BaseSimpleCollectible.MixedSimpleCollectibleDetail {
        return BaseSimpleCollectible.MixedSimpleCollectibleDetail(
            assetId = assetDetailDTO.assetId,
            fullName = assetDetailDTO.fullName,
            shortName = assetDetailDTO.shortName,
            isVerified = assetDetailDTO.isVerified,
            fractionDecimals = assetDetailDTO.fractionDecimals,
            usdValue = assetDetailDTO.usdValue,
            assetCreator = assetDetailDTO.assetCreator,
            title = assetDetailDTO.collectible?.title,
            collectionName = assetDetailDTO.collectible?.collectionName,
            thumbnailPrismUrl = assetDetailDTO.collectible?.primaryImageUrl
        )
    }

    fun mapToNotSupportedSimpleCollectibleDetail(
        assetDetailDTO: AssetDetailDTO
    ): BaseSimpleCollectible.NotSupportedSimpleCollectibleDetail {
        return BaseSimpleCollectible.NotSupportedSimpleCollectibleDetail(
            assetId = assetDetailDTO.assetId,
            fullName = assetDetailDTO.fullName,
            shortName = assetDetailDTO.shortName,
            isVerified = assetDetailDTO.isVerified,
            fractionDecimals = assetDetailDTO.fractionDecimals,
            usdValue = assetDetailDTO.usdValue,
            assetCreator = assetDetailDTO.assetCreator,
            title = assetDetailDTO.collectible?.title,
            collectionName = assetDetailDTO.collectible?.collectionName
        )
    }
}
