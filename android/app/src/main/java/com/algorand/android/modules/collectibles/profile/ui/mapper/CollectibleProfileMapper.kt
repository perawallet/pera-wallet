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

package com.algorand.android.modules.collectibles.profile.ui.mapper

import com.algorand.android.models.Account
import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.modules.collectibles.profile.ui.model.CollectibleProfile
import com.algorand.android.nft.domain.decider.CollectibleDetailDecider
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleMedia
import com.algorand.android.nft.mapper.CollectibleMediaItemMapper
import com.algorand.android.nft.mapper.CollectibleTraitItemMapper
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import javax.inject.Inject

class CollectibleProfileMapper @Inject constructor(
    private val collectibleDetailDecider: CollectibleDetailDecider,
    private val collectibleTraitItemMapper: CollectibleTraitItemMapper,
    private val collectibleMediaItemMapper: CollectibleMediaItemMapper
) {

    fun mapToCollectibleProfile(
        collectibleDetail: BaseCollectibleDetail,
        creatorWalletAddress: BaseAccountAddress.AccountAddress?,
        ownerAccountType: Account.Type?,
        prismUrl: String?,
        isOwnedByTheUser: Boolean,
        errorDisplayText: String,
    ): CollectibleProfile {
        return with(collectibleDetail) {
            CollectibleProfile(
                collectionName = collectionName,
                collectibleName = title,
                collectibleDescription = description,
                collectibleId = assetId,
                creatorName = "", // todo it's an optional field and we don't know json field name yet
                creatorWalletAddress = creatorWalletAddress,
                warningTextRes = collectibleDetailDecider.decideWarningTextRes(prismUrl),
                collectibleTraits = traits?.map { collectibleTraitItemMapper.mapToTraitItem(it) },
                isPeraExplorerVisible = !nftExplorerUrl.isNullOrBlank(),
                peraExplorerUrl = nftExplorerUrl,
                collectibleMedias = createCollectibleMedias(
                    collectibleMedias = collectibleMedias,
                    assetId = assetId,
                    isOwnedByTheUser = isOwnedByTheUser,
                    errorDisplayText = errorDisplayText
                ),
                optedInWarningTextRes = collectibleDetailDecider.decideOptedInWarningTextRes(
                    isOwnedByTheUser = isOwnedByTheUser,
                    accountType = ownerAccountType
                ),
                prismUrl = prismUrl,
                isOwnedByTheUser = isOwnedByTheUser
            )
        }
    }

    private fun createCollectibleMedias(
        collectibleMedias: List<BaseCollectibleMedia>?,
        assetId: Long,
        isOwnedByTheUser: Boolean,
        errorDisplayText: String
    ): List<BaseCollectibleMediaItem> {
        return collectibleMedias?.map {
            when (it) {
                is BaseCollectibleMedia.GifCollectibleMedia -> {
                    collectibleMediaItemMapper.mapToGifCollectibleMediaItem(
                        collectibleId = assetId,
                        isOwnedByTheUser = isOwnedByTheUser,
                        errorText = errorDisplayText,
                        collectibleMedia = it
                    )
                }
                else -> {
                    collectibleMediaItemMapper.mapToImageCollectibleMediaItem(
                        collectibleId = assetId,
                        isOwnedByTheUser = isOwnedByTheUser,
                        errorText = errorDisplayText,
                        collectibleMedia = it
                    )
                }
            }
        }.orEmpty()
    }
}
