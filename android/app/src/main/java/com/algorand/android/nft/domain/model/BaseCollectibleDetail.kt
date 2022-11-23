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

package com.algorand.android.nft.domain.model

import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.models.AssetCreator
import com.algorand.android.models.BaseAssetDetail
import java.math.BigDecimal
import java.math.BigInteger

sealed class BaseCollectibleDetail(
    override val assetId: Long,
    override val fullName: String?,
    override val shortName: String?,
    override val fractionDecimals: Int?,
    override val usdValue: BigDecimal?,
    override val assetCreator: AssetCreator?
) : BaseAssetDetail() {

    abstract val title: String?
    abstract val collectionName: String?
    abstract val description: String?
    abstract val traits: List<CollectibleTrait>?
    abstract val nftExplorerUrl: String?

    abstract val collectibleMedias: List<BaseCollectibleMedia>?

    fun isPure(): Boolean {
        return if (maxSupply == null) false else maxSupply == BigInteger.ONE && fractionDecimals == 0
    }

    fun getErrorDisplayText(): String {
        return title ?: fullName ?: shortName ?: assetId.toString()
    }

    data class ImageCollectibleDetail(
        override val assetId: Long,
        override val fullName: String?,
        override val shortName: String?,
        override val fractionDecimals: Int?,
        override val usdValue: BigDecimal?,
        override val assetCreator: AssetCreator?,
        override val title: String?,
        override val collectionName: String?,
        override val description: String?,
        override val traits: List<CollectibleTrait>?,
        override val nftExplorerUrl: String?,
        override val collectibleMedias: List<BaseCollectibleMedia>?,
        override val totalSupply: BigDecimal?,
        override val verificationTier: VerificationTier,
        override val logoUri: String?,
        override val logoSvgUri: String?,
        override val explorerUrl: String?,
        override val projectUrl: String?,
        override val projectName: String?,
        override val discordUrl: String?,
        override val telegramUrl: String?,
        override val twitterUsername: String?,
        override val assetDescription: String?,
        override val url: String?,
        override val maxSupply: BigInteger?,
        val prismUrl: String?,
    ) : BaseCollectibleDetail(assetId, fullName, shortName, fractionDecimals, usdValue, assetCreator)

    data class NotSupportedCollectibleDetail(
        override val assetId: Long,
        override val fullName: String?,
        override val shortName: String?,
        override val fractionDecimals: Int?,
        override val usdValue: BigDecimal?,
        override val assetCreator: AssetCreator?,
        override val title: String?,
        override val collectionName: String?,
        override val description: String?,
        override val traits: List<CollectibleTrait>?,
        override val nftExplorerUrl: String?,
        override val collectibleMedias: List<BaseCollectibleMedia>?,
        override val totalSupply: BigDecimal?,
        override val verificationTier: VerificationTier,
        override val logoUri: String?,
        override val logoSvgUri: String?,
        override val explorerUrl: String?,
        override val projectUrl: String?,
        override val projectName: String?,
        override val discordUrl: String?,
        override val telegramUrl: String?,
        override val twitterUsername: String?,
        override val url: String?,
        override val assetDescription: String?,
        override val maxSupply: BigInteger?
    ) : BaseCollectibleDetail(assetId, fullName, shortName, fractionDecimals, usdValue, assetCreator)

    data class VideoCollectibleDetail(
        override val assetId: Long,
        override val fullName: String?,
        override val shortName: String?,
        override val fractionDecimals: Int?,
        override val usdValue: BigDecimal?,
        override val assetCreator: AssetCreator?,
        override val title: String?,
        override val collectionName: String?,
        override val description: String?,
        override val traits: List<CollectibleTrait>?,
        override val nftExplorerUrl: String?,
        override val collectibleMedias: List<BaseCollectibleMedia>?,
        override val totalSupply: BigDecimal?,
        override val verificationTier: VerificationTier,
        override val logoUri: String?,
        override val logoSvgUri: String?,
        override val explorerUrl: String?,
        override val projectUrl: String?,
        override val projectName: String?,
        override val discordUrl: String?,
        override val telegramUrl: String?,
        override val twitterUsername: String?,
        override val assetDescription: String?,
        override val url: String?,
        override val maxSupply: BigInteger?,
        val thumbnailPrismUrl: String?
    ) : BaseCollectibleDetail(assetId, fullName, shortName, fractionDecimals, usdValue, assetCreator)

    data class AudioCollectibleDetail(
        override val assetId: Long,
        override val fullName: String?,
        override val shortName: String?,
        override val fractionDecimals: Int?,
        override val usdValue: BigDecimal?,
        override val assetCreator: AssetCreator?,
        override val title: String?,
        override val collectionName: String?,
        override val description: String?,
        override val traits: List<CollectibleTrait>?,
        override val nftExplorerUrl: String?,
        override val collectibleMedias: List<BaseCollectibleMedia>?,
        override val totalSupply: BigDecimal?,
        override val verificationTier: VerificationTier,
        override val logoUri: String?,
        override val logoSvgUri: String?,
        override val explorerUrl: String?,
        override val projectUrl: String?,
        override val projectName: String?,
        override val discordUrl: String?,
        override val telegramUrl: String?,
        override val twitterUsername: String?,
        override val assetDescription: String?,
        override val url: String?,
        override val maxSupply: BigInteger?,
        val thumbnailPrismUrl: String?
    ) : BaseCollectibleDetail(assetId, fullName, shortName, fractionDecimals, usdValue, assetCreator)

    data class MixedCollectibleDetail(
        override val assetId: Long,
        override val fullName: String?,
        override val shortName: String?,
        override val fractionDecimals: Int?,
        override val usdValue: BigDecimal?,
        override val assetCreator: AssetCreator?,
        override val title: String?,
        override val collectionName: String?,
        override val description: String?,
        override val traits: List<CollectibleTrait>?,
        override val nftExplorerUrl: String?,
        override val collectibleMedias: List<BaseCollectibleMedia>?,
        override val totalSupply: BigDecimal?,
        override val verificationTier: VerificationTier,
        override val logoUri: String?,
        override val logoSvgUri: String?,
        override val explorerUrl: String?,
        override val projectUrl: String?,
        override val projectName: String?,
        override val discordUrl: String?,
        override val telegramUrl: String?,
        override val twitterUsername: String?,
        override val assetDescription: String?,
        override val maxSupply: BigInteger?,
        override val url: String?,
        val thumbnailPrismUrl: String?
    ) : BaseCollectibleDetail(assetId, fullName, shortName, fractionDecimals, usdValue, assetCreator)
}
