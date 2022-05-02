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

import com.algorand.android.nft.domain.model.BaseCollectibleDetail.ImageCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleDetail.MixedCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleDetail.NotSupportedCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleDetail.VideoCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleMedia
import com.algorand.android.nft.domain.model.CollectibleDetailDTO
import javax.inject.Inject

class CollectibleDetailMapper @Inject constructor() {

    fun mapToImageCollectibleDetail(collectibleDetailDTO: CollectibleDetailDTO): ImageCollectibleDetail {
        return ImageCollectibleDetail(
            assetId = collectibleDetailDTO.collectibleAssetId,
            fullName = collectibleDetailDTO.fullName,
            shortName = collectibleDetailDTO.shortName,
            isVerified = collectibleDetailDTO.isVerified,
            fractionDecimals = collectibleDetailDTO.fractionDecimals,
            usdValue = collectibleDetailDTO.usdValue,
            assetCreator = collectibleDetailDTO.assetCreator,
            collectionName = collectibleDetailDTO.collectionName,
            title = collectibleDetailDTO.title,
            description = collectibleDetailDTO.description,
            traits = collectibleDetailDTO.traits,
            prismUrl = collectibleDetailDTO.primaryImageUrl,
            nftExplorerUrl = collectibleDetailDTO.explorerUrl,
            collectibleMedias = collectibleDetailDTO.medias,
            totalSupply = collectibleDetailDTO.totalSupply
        )
    }

    fun mapToNotSupportedCollectibleDetail(collectibleDetailDTO: CollectibleDetailDTO): NotSupportedCollectibleDetail {
        val collectibleMedias = if (collectibleDetailDTO.medias.isEmpty()) {
            listOf(BaseCollectibleMedia.NoMediaCollectibleMedia(null, null))
        } else {
            collectibleDetailDTO.medias
        }
        return NotSupportedCollectibleDetail(
            assetId = collectibleDetailDTO.collectibleAssetId,
            fullName = collectibleDetailDTO.fullName,
            shortName = collectibleDetailDTO.shortName,
            isVerified = collectibleDetailDTO.isVerified,
            fractionDecimals = collectibleDetailDTO.fractionDecimals,
            usdValue = collectibleDetailDTO.usdValue,
            assetCreator = collectibleDetailDTO.assetCreator,
            collectionName = collectibleDetailDTO.collectionName,
            title = collectibleDetailDTO.title,
            description = collectibleDetailDTO.description,
            traits = collectibleDetailDTO.traits,
            nftExplorerUrl = collectibleDetailDTO.explorerUrl,
            collectibleMedias = collectibleMedias,
            totalSupply = collectibleDetailDTO.totalSupply
        )
    }

    fun mapToVideoCollectibleDetail(
        collectibleDetailDTO: CollectibleDetailDTO,
        thumbnailPrismUrl: String
    ): VideoCollectibleDetail {
        return VideoCollectibleDetail(
            assetId = collectibleDetailDTO.collectibleAssetId,
            fullName = collectibleDetailDTO.fullName,
            shortName = collectibleDetailDTO.shortName,
            isVerified = collectibleDetailDTO.isVerified,
            fractionDecimals = collectibleDetailDTO.fractionDecimals,
            usdValue = collectibleDetailDTO.usdValue,
            assetCreator = collectibleDetailDTO.assetCreator,
            collectionName = collectibleDetailDTO.collectionName,
            title = collectibleDetailDTO.title,
            description = collectibleDetailDTO.description,
            traits = collectibleDetailDTO.traits,
            thumbnailPrismUrl = thumbnailPrismUrl,
            nftExplorerUrl = collectibleDetailDTO.explorerUrl,
            collectibleMedias = collectibleDetailDTO.medias,
            totalSupply = collectibleDetailDTO.totalSupply
        )
    }

    fun mapToMixedCollectibleDetail(collectibleDetailDTO: CollectibleDetailDTO): MixedCollectibleDetail {
        return MixedCollectibleDetail(
            assetId = collectibleDetailDTO.collectibleAssetId,
            fullName = collectibleDetailDTO.fullName,
            shortName = collectibleDetailDTO.shortName,
            isVerified = collectibleDetailDTO.isVerified,
            fractionDecimals = collectibleDetailDTO.fractionDecimals,
            usdValue = collectibleDetailDTO.usdValue,
            assetCreator = collectibleDetailDTO.assetCreator,
            collectionName = collectibleDetailDTO.collectionName,
            title = collectibleDetailDTO.title,
            description = collectibleDetailDTO.description,
            traits = collectibleDetailDTO.traits,
            thumbnailPrismUrl = collectibleDetailDTO.primaryImageUrl,
            nftExplorerUrl = collectibleDetailDTO.explorerUrl,
            collectibleMedias = collectibleDetailDTO.medias,
            totalSupply = collectibleDetailDTO.totalSupply
        )
    }
}
