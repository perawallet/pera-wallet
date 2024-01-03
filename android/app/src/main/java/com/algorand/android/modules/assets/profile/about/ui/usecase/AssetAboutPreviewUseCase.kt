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

package com.algorand.android.modules.assets.profile.about.ui.usecase

import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.assetsearch.domain.model.VerificationTier.SUSPICIOUS
import com.algorand.android.assetsearch.domain.model.VerificationTier.TRUSTED
import com.algorand.android.assetsearch.domain.model.VerificationTier.UNVERIFIED
import com.algorand.android.assetsearch.domain.model.VerificationTier.VERIFIED
import com.algorand.android.models.AssetCreator
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.modules.assets.profile.about.domain.usecase.CacheAssetDetailToAsaProfileLocalCacheUseCase
import com.algorand.android.modules.assets.profile.about.domain.usecase.ClearAsaProfileLocalCacheUseCase
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetAssetDetailFlowFromAsaProfileLocalCache
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetSelectedAssetExchangeValueUseCase
import com.algorand.android.modules.assets.profile.about.ui.mapper.AssetAboutPreviewMapper
import com.algorand.android.modules.assets.profile.about.ui.mapper.BaseAssetAboutListItemMapper
import com.algorand.android.modules.assets.profile.about.ui.model.AssetAboutPreview
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem
import com.algorand.android.modules.assets.profile.asaprofile.ui.usecase.AsaProfilePreviewUseCase.Companion.MINIMUM_CURRENCY_VALUE_TO_DISPLAY_EXACT_AMOUNT
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.browser.addProtocolIfNeed
import com.algorand.android.utils.browser.removeProtocolIfNeed
import com.algorand.android.utils.formatAmount
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class AssetAboutPreviewUseCase @Inject constructor(
    private val cacheAssetDetailToAsaProfileLocalCacheUseCase: CacheAssetDetailToAsaProfileLocalCacheUseCase,
    private val getAssetDetailFlowFromAsaProfileLocalCache: GetAssetDetailFlowFromAsaProfileLocalCache,
    private val clearAsaProfileLocalCacheUseCase: ClearAsaProfileLocalCacheUseCase,
    private val assetAboutPreviewMapper: AssetAboutPreviewMapper,
    private val baseAssetAboutListItemMapper: BaseAssetAboutListItemMapper,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val getSelectedAssetExchangeValueUseCase: GetSelectedAssetExchangeValueUseCase
) {

    fun clearAsaProfileLocalCache() {
        clearAsaProfileLocalCacheUseCase.clearAsaProfileLocalCache()
    }

    suspend fun cacheAssetDetailToAsaProfileLocalCache(assetId: Long) {
        cacheAssetDetailToAsaProfileLocalCacheUseCase.cacheAssetDetailToAsaProfileLocalCache(assetId)
    }

    fun getAssetAboutPreview(assetId: Long) = flow {
        emit(assetAboutPreviewMapper.mapToAssetAboutPreviewInitialState())
        if (assetId == ALGO_ID) {
            val cachedAlgoAssetDetail = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)
            cachedAlgoAssetDetail?.useSuspended(
                onSuccess = { cachedAlgoDetail ->
                    val algoAboutPreview = cachedAlgoDetail.data?.run { createAlgoAboutPreview(this) }
                    emit(algoAboutPreview)
                }
            )
        } else {
            getAssetDetailFlowFromAsaProfileLocalCache.getAssetDetailFlowFromAsaProfileLocalCache()
                .collect { cacheResult ->
                    cacheResult?.useSuspended(
                        onSuccess = { cachedAssetDetail ->
                            cachedAssetDetail.data?.let { assetDetail ->
                                emit(createAssetAboutPreview(assetDetail))
                            }
                        }
                    )
                }
        }
    }

    private fun createAlgoAboutPreview(assetDetail: BaseAssetDetail): AssetAboutPreview {
        val algorandAboutList = mutableListOf<BaseAssetAboutListItem>().apply {
            with(assetDetail) {
                add(createStatisticsItem(this))
                add(BaseAssetAboutListItem.DividerItem)
                add(
                    createAboutAssetItem(
                        fullName = fullName,
                        assetId = null,
                        assetCreator = null,
                        explorerUrl = null,
                        projectUrl = null,
                        asaUrl = url
                    )
                )
                add(BaseAssetAboutListItem.DividerItem)
                add(createAlgoDescriptionItem(R.string.the_algo_is_the_official_cryptocurrency))
                createSocialMediaItem(discordUrl, telegramUrl, twitterUsername)?.run {
                    add(BaseAssetAboutListItem.DividerItem)
                    add(this)
                }
                addVerificationTierDescriptionIfNeed(this@apply, verificationTier)
            }
        }
        return assetAboutPreviewMapper.mapToAssetAboutPreview(assetAboutListItems = algorandAboutList)
    }

    private fun createAssetAboutPreview(assetDetail: BaseAssetDetail): AssetAboutPreview {
        val assetAboutList = mutableListOf<BaseAssetAboutListItem>().apply {
            with(assetDetail) {

                add(createStatisticsItem(this))
                add(BaseAssetAboutListItem.DividerItem)

                add(createAboutAssetItem(fullName, assetId, assetCreator, explorerUrl, projectUrl, url))

                createAssetDescriptionItem(assetDescription)?.run {
                    add(BaseAssetAboutListItem.DividerItem)
                    add(this)
                }

                createSocialMediaItem(discordUrl, telegramUrl, twitterUsername)?.run {
                    add(BaseAssetAboutListItem.DividerItem)
                    add(this)
                }
                addReportItemIfNeed(this@apply, verificationTier, assetId, shortName)
                addVerificationTierDescriptionIfNeed(this@apply, verificationTier)
            }
        }
        return assetAboutPreviewMapper.mapToAssetAboutPreview(assetAboutListItems = assetAboutList)
    }

    private fun addVerificationTierDescriptionIfNeed(
        assetAboutList: MutableList<BaseAssetAboutListItem>,
        verificationTier: VerificationTier
    ) {
        val position = when (verificationTier) {
            TRUSTED, VERIFIED -> assetAboutList.indexOfFirst { it is BaseAssetAboutListItem.AboutAssetItem } + 1
            SUSPICIOUS -> assetAboutList.indexOfFirst { it is BaseAssetAboutListItem.StatisticsItem }
            UNVERIFIED -> null
        }
        val item = when (verificationTier) {
            VERIFIED -> BaseAssetAboutListItem.BadgeDescriptionItem.VerifiedBadgeItem
            TRUSTED -> BaseAssetAboutListItem.BadgeDescriptionItem.TrustedBadgeItem
            SUSPICIOUS -> BaseAssetAboutListItem.BadgeDescriptionItem.SuspiciousBadgeItem
            UNVERIFIED -> null
        }
        if (item != null && position != null) {
            assetAboutList.add(position, item)
        }
    }

    private fun addReportItemIfNeed(
        mutableList: MutableList<BaseAssetAboutListItem>,
        verificationTier: VerificationTier,
        assetId: Long,
        shortName: String?
    ) {
        if (verificationTier != TRUSTED) {
            mutableList.add(BaseAssetAboutListItem.DividerItem)
            mutableList.add(createReportItem(assetId, shortName))
        }
    }

    private fun createStatisticsItem(assetDetail: BaseAssetDetail): BaseAssetAboutListItem.StatisticsItem {
        with(assetDetail) {
            val minAmountToDisplay = BigDecimal.valueOf(MINIMUM_CURRENCY_VALUE_TO_DISPLAY_EXACT_AMOUNT)
            val formattedAssetPrice = getSelectedAssetExchangeValueUseCase
                .getSelectedAssetExchangeValue(assetDetail = this)
                ?.getFormattedValue(minValueToDisplayExactAmount = minAmountToDisplay)
            return baseAssetAboutListItemMapper.mapToStatisticsItem(
                formattedPriceText = formattedAssetPrice,
                formattedCompactTotalSupplyText = totalSupply?.formatAmount(
                    decimals = fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
                    isCompact = true,
                    isDecimalFixed = false
                )
            )
        }
    }

    private fun createAboutAssetItem(
        fullName: String?,
        assetId: Long?,
        assetCreator: AssetCreator?,
        explorerUrl: String?,
        projectUrl: String?,
        asaUrl: String?
    ): BaseAssetAboutListItem.AboutAssetItem {
        return baseAssetAboutListItemMapper.mapToAboutAssetItem(
            assetName = AssetName.create(fullName),
            assetId = assetId,
            assetCreatorAddress = assetCreator?.publicKey,
            asaUrl = asaUrl.addProtocolIfNeed(),
            displayAsaUrl = asaUrl.removeProtocolIfNeed(),
            peraExplorerUrl = explorerUrl,
            projectWebsiteUrl = projectUrl
        )
    }

    private fun createAssetDescriptionItem(
        assetDescription: String?
    ): BaseAssetAboutListItem.BaseAssetDescriptionItem.AssetDescriptionItem? {
        if (assetDescription.isNullOrBlank()) return null
        return baseAssetAboutListItemMapper.mapToAssetDescriptionItem(descriptionText = assetDescription)
    }

    private fun createAlgoDescriptionItem(
        @StringRes descriptionTextResId: Int
    ): BaseAssetAboutListItem.BaseAssetDescriptionItem.AlgoDescriptionItem {
        return baseAssetAboutListItemMapper.mapToAlgoDescriptionItem(descriptionTextResId = descriptionTextResId)
    }

    private fun createSocialMediaItem(
        discordUrl: String?,
        telegramUrl: String?,
        twitterUsername: String?
    ): BaseAssetAboutListItem.SocialMediaItem? {
        if (discordUrl.isNullOrBlank() && telegramUrl.isNullOrBlank() && twitterUsername.isNullOrBlank()) return null
        return baseAssetAboutListItemMapper.mapToSocialMediaItem(
            discordUrl = discordUrl,
            telegramUrl = telegramUrl,
            twitterUsername = twitterUsername
        )
    }

    private fun createReportItem(assetId: Long, shortName: String?): BaseAssetAboutListItem.ReportItem {
        return baseAssetAboutListItemMapper.mapToReportItem(
            assetName = AssetName.createShortName(shortName),
            assetId = assetId
        )
    }
}
