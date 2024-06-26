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

package com.algorand.android.modules.collectibles.detail.base.data.model

import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.models.AssetCreator
import com.algorand.android.nft.domain.model.BaseCollectibleMedia
import com.algorand.android.nft.domain.model.CollectibleMediaType
import com.algorand.android.nft.domain.model.CollectibleTrait
import java.math.BigDecimal
import java.math.BigInteger

data class CollectibleDetailDTO(
    val collectibleAssetId: Long,
    val fullName: String?,
    val shortName: String?,
    val fractionDecimals: Int,
    val usdValue: BigDecimal?,
    val assetCreator: AssetCreator?,
    val mediaType: CollectibleMediaType,
    val primaryImageUrl: String?,
    val title: String?,
    val collectionName: String?,
    val description: String?,
    val traits: List<CollectibleTrait>,
    val medias: List<BaseCollectibleMedia>,
    val explorerUrl: String?,
    val totalSupply: BigDecimal?,
    val verificationTier: VerificationTier,
    val logoUri: String?,
    val logoSvgUri: String?,
    val projectUrl: String?,
    val projectName: String?,
    val discordUrl: String?,
    val telegramUrl: String?,
    val twitterUsername: String?,
    val assetDescription: String?,
    val url: String?,
    val maxSupply: BigInteger?,
    val last24HoursAlgoPriceChangePercentage: BigDecimal?,
    val isAvailableOnDiscoverMobile: Boolean?
)
