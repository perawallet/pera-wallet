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

package com.algorand.android.nft.mapper

import com.algorand.android.models.Account
import com.algorand.android.nft.domain.decider.CollectibleDetailDecider
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.ui.model.CollectibleDetail
import javax.inject.Inject

class CollectibleDetailMapper @Inject constructor(
    private val collectibleDetailDecider: CollectibleDetailDecider,
    private val collectibleTraitItemMapper: CollectibleTraitItemMapper,
    private val collectibleMediaItemMapper: CollectibleMediaItemMapper
) {

    fun mapToCollectibleImage(
        imageCollectibleDetail: BaseCollectibleDetail.ImageCollectibleDetail,
        isOwnedByTheUser: Boolean,
        ownerAccount: Account?,
        errorDisplayText: String,
        isHoldingByWatchAccount: Boolean,
        isNftExplorerVisible: Boolean
    ): CollectibleDetail.ImageCollectibleDetail {
        return CollectibleDetail.ImageCollectibleDetail(
            isOwnedByTheUser = isOwnedByTheUser,
            collectionName = imageCollectibleDetail.collectionName,
            collectibleName = imageCollectibleDetail.title,
            collectibleDescription = imageCollectibleDetail.description,
            ownerAccountAddress = ownerAccount?.address,
            ownerAccountIcon = ownerAccount?.createAccountIcon(),
            collectibleId = imageCollectibleDetail.assetId,
            creatorName = "", // todo it's an optional field and we don't know json field name yet
            creatorWalletAddress = imageCollectibleDetail.assetCreator?.publicKey,
            prismUrl = imageCollectibleDetail.prismUrl,
            collectibleTraits = imageCollectibleDetail.traits?.map { collectibleTraitItemMapper.mapToTraitItem(it) },
            isHoldingByWatchAccount = isHoldingByWatchAccount,
            warningTextRes = collectibleDetailDecider.decideWarningTextRes(imageCollectibleDetail.prismUrl),
            isPeraExplorerVisible = isNftExplorerVisible,
            peraExplorerUrl = imageCollectibleDetail.nftExplorerUrl,
            isVerified = imageCollectibleDetail.isVerified,
            collectibleMedias = imageCollectibleDetail.collectibleMedias?.map {
                collectibleMediaItemMapper.mapToImageCollectibleMediaItem(
                    imageCollectibleDetail.assetId,
                    isOwnedByTheUser,
                    errorDisplayText,
                    it
                )
            }.orEmpty()
        )
    }

    fun mapToCollectibleVideo(
        videoCollectibleDetail: BaseCollectibleDetail.VideoCollectibleDetail,
        isOwnedByTheUser: Boolean,
        ownerAccount: Account?,
        errorDisplayText: String,
        isHoldingByWatchAccount: Boolean,
        isNftExplorerVisible: Boolean
    ): CollectibleDetail.VideoCollectibleDetail {
        return CollectibleDetail.VideoCollectibleDetail(
            isOwnedByTheUser = isOwnedByTheUser,
            collectionName = videoCollectibleDetail.collectionName,
            collectibleName = videoCollectibleDetail.title,
            collectibleDescription = videoCollectibleDetail.description,
            ownerAccountAddress = ownerAccount?.address,
            ownerAccountIcon = ownerAccount?.createAccountIcon(),
            collectibleId = videoCollectibleDetail.assetId,
            creatorName = "", // todo it's an optional field and we don't know json field name yet
            creatorWalletAddress = videoCollectibleDetail.assetCreator?.publicKey,
            collectibleTraits = videoCollectibleDetail.traits?.map { collectibleTraitItemMapper.mapToTraitItem(it) },
            isHoldingByWatchAccount = isHoldingByWatchAccount,
            warningTextRes = collectibleDetailDecider.decideWarningTextRes(videoCollectibleDetail.thumbnailPrismUrl),
            prismUrl = videoCollectibleDetail.thumbnailPrismUrl,
            isPeraExplorerVisible = isNftExplorerVisible,
            peraExplorerUrl = videoCollectibleDetail.nftExplorerUrl,
            isVerified = videoCollectibleDetail.isVerified,
            collectibleMedias = videoCollectibleDetail.collectibleMedias?.map {
                collectibleMediaItemMapper.mapToVideoCollectibleMediaItem(
                    videoCollectibleDetail.assetId,
                    isOwnedByTheUser,
                    errorDisplayText,
                    it,
                    videoCollectibleDetail.thumbnailPrismUrl.orEmpty()
                )
            }.orEmpty()
        )
    }

    fun mapToCollectibleMixed(
        mixedCollectibleDetail: BaseCollectibleDetail.MixedCollectibleDetail,
        isOwnedByTheUser: Boolean,
        ownerAccount: Account?,
        isHoldingByWatchAccount: Boolean,
        isNftExplorerVisible: Boolean,
        collectibleMedias: List<BaseCollectibleMediaItem>
    ): CollectibleDetail.MixedCollectibleDetail {
        return CollectibleDetail.MixedCollectibleDetail(
            isOwnedByTheUser = isOwnedByTheUser,
            collectionName = mixedCollectibleDetail.collectionName,
            collectibleName = mixedCollectibleDetail.title,
            collectibleDescription = mixedCollectibleDetail.description,
            ownerAccountAddress = ownerAccount?.address,
            ownerAccountIcon = ownerAccount?.createAccountIcon(),
            collectibleId = mixedCollectibleDetail.assetId,
            creatorName = "", // todo it's an optional field and we don't know json field name yet
            creatorWalletAddress = mixedCollectibleDetail.assetCreator?.publicKey,
            collectibleTraits = mixedCollectibleDetail.traits?.map { collectibleTraitItemMapper.mapToTraitItem(it) },
            isHoldingByWatchAccount = isHoldingByWatchAccount,
            warningTextRes = collectibleDetailDecider.decideWarningTextRes(mixedCollectibleDetail.thumbnailPrismUrl),
            prismUrl = mixedCollectibleDetail.thumbnailPrismUrl,
            isPeraExplorerVisible = isNftExplorerVisible,
            peraExplorerUrl = mixedCollectibleDetail.nftExplorerUrl,
            collectibleMedias = collectibleMedias,
            isVerified = mixedCollectibleDetail.isVerified
        )
    }

    fun mapToUnsupportedCollectible(
        unsupportedCollectible: BaseCollectibleDetail.NotSupportedCollectibleDetail,
        isOwnedByTheUser: Boolean,
        ownerAccount: Account?,
        errorDisplayText: String,
        isHoldingByWatchAccount: Boolean,
        warningTextRes: Int?,
        isNftExplorerVisible: Boolean
    ): CollectibleDetail.NotSupportedCollectibleDetail {
        return CollectibleDetail.NotSupportedCollectibleDetail(
            isOwnedByTheUser = isOwnedByTheUser,
            collectionName = unsupportedCollectible.collectionName,
            collectibleName = unsupportedCollectible.title,
            collectibleDescription = unsupportedCollectible.description,
            ownerAccountAddress = ownerAccount?.address,
            ownerAccountIcon = ownerAccount?.createAccountIcon(),
            collectibleId = unsupportedCollectible.assetId,
            creatorName = "", // todo it's an optional field and we don't know json field name yet
            creatorWalletAddress = unsupportedCollectible.assetCreator?.publicKey,
            collectibleTraits = unsupportedCollectible.traits?.map { collectibleTraitItemMapper.mapToTraitItem(it) },
            isHoldingByWatchAccount = isHoldingByWatchAccount,
            warningTextRes = warningTextRes,
            isPeraExplorerVisible = isNftExplorerVisible,
            peraExplorerUrl = unsupportedCollectible.nftExplorerUrl,
            isVerified = unsupportedCollectible.isVerified,
            collectibleMedias = unsupportedCollectible.collectibleMedias?.map {
                collectibleMediaItemMapper.mapToUnsupportedCollectibleMediaItem(
                    unsupportedCollectible.assetId,
                    isOwnedByTheUser,
                    errorDisplayText,
                    it
                )
            }.orEmpty()
        )
    }
}
