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

package com.algorand.android.modules.assets.profile.about.ui.model

import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.browser.ASA_VERIFICATION_URL

sealed class BaseAssetAboutListItem : RecyclerListItem {

    enum class ItemType {
        STATISTICS_ITEM,
        ABOUT_ASSET_ITEM,
        BADGE_DESCRIPTION_ITEM,
        ASSET_DESCRIPTION_ITEM,
        ALGO_DESCRIPTION_ITEM,
        SOCIAL_MEDIA_ITEM,
        REPORT_ITEM,
        DIVIDER_ITEM
    }

    abstract val itemType: ItemType

    data class StatisticsItem(
        val formattedPriceText: String?,
        val formattedCompactTotalSupplyText: String?
    ) : BaseAssetAboutListItem() {

        override val itemType = ItemType.STATISTICS_ITEM

        val hasPriceInfo: Boolean
            get() = formattedPriceText.isNullOrBlank().not()

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is StatisticsItem &&
                formattedPriceText == other.formattedPriceText &&
                formattedCompactTotalSupplyText == other.formattedCompactTotalSupplyText
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is StatisticsItem && this == other
        }
    }

    data class AboutAssetItem(
        val assetName: AssetName,
        val assetId: Long?,
        val assetCreatorAddress: String?,
        val asaUrl: String?,
        val displayAsaUrl: String?,
        val peraExplorerUrl: String?,
        val projectWebsiteUrl: String?
    ) : BaseAssetAboutListItem() {

        override val itemType = ItemType.ABOUT_ASSET_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AboutAssetItem && assetId == other.assetId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AboutAssetItem && this == other
        }
    }

    sealed class BadgeDescriptionItem : BaseAssetAboutListItem() {

        val learnMoreAboutAsaUrl: String = ASA_VERIFICATION_URL

        abstract val backgroundColorResId: Int
        abstract val textColorResId: Int
        abstract val drawableResId: Int
        abstract val titleTextResId: Int
        abstract val descriptionTextResId: Int

        override val itemType = ItemType.BADGE_DESCRIPTION_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is BadgeDescriptionItem &&
                drawableResId == other.drawableResId &&
                titleTextResId == other.titleTextResId &&
                descriptionTextResId == other.descriptionTextResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is BadgeDescriptionItem && this == other
        }

        object TrustedBadgeItem : BadgeDescriptionItem() {
            override val backgroundColorResId: Int = R.color.trusted_icon_bg_opacity_16
            override val textColorResId: Int = R.color.positive
            override val drawableResId: Int = R.drawable.ic_asa_trusted
            override val titleTextResId: Int = R.string.trusted_asa
            override val descriptionTextResId: Int = R.string.this_is_a_well_known
        }

        object VerifiedBadgeItem : BadgeDescriptionItem() {
            override val backgroundColorResId: Int = R.color.verified_icon_bg_opacity_80
            override val textColorResId: Int = R.color.verified_icon_inline
            override val drawableResId: Int = R.drawable.ic_asa_verified_opposite
            override val titleTextResId: Int = R.string.verified_asa
            override val descriptionTextResId: Int = R.string.this_asa_was_automatically_verified
        }

        object SuspiciousBadgeItem : BadgeDescriptionItem() {
            override val backgroundColorResId: Int = R.color.suspicious_icon_bg_opacity_16
            override val textColorResId: Int = R.color.negative
            override val drawableResId: Int = R.drawable.ic_asa_danger
            override val titleTextResId: Int = R.string.suspicious
            override val descriptionTextResId: Int = R.string.we_ve_received_reports_that
        }
    }

    sealed class BaseAssetDescriptionItem : BaseAssetAboutListItem() {

        data class AssetDescriptionItem(val descriptionText: String) : BaseAssetDescriptionItem() {

            override val itemType = ItemType.ASSET_DESCRIPTION_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AssetDescriptionItem && descriptionText == other.descriptionText
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AssetDescriptionItem && this == other
            }
        }

        data class AlgoDescriptionItem(@StringRes val descriptionTextResId: Int) : BaseAssetDescriptionItem() {

            override val itemType = ItemType.ALGO_DESCRIPTION_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AlgoDescriptionItem && descriptionTextResId == other.descriptionTextResId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AlgoDescriptionItem && this == other
            }
        }
    }

    data class SocialMediaItem(
        val discordUrl: String?,
        val telegramUrl: String?,
        val twitterUrl: String?
    ) : BaseAssetAboutListItem() {

        override val itemType = ItemType.SOCIAL_MEDIA_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SocialMediaItem &&
                discordUrl == other.discordUrl &&
                telegramUrl == other.telegramUrl &&
                twitterUrl == other.twitterUrl
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SocialMediaItem && this == other
        }
    }

    data class ReportItem(
        val assetName: AssetName,
        val assetId: Long
    ) : BaseAssetAboutListItem() {

        override val itemType = ItemType.REPORT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ReportItem && assetName == other.assetName && assetId == other.assetId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ReportItem && this == other
        }
    }

    object DividerItem : BaseAssetAboutListItem() {

        override val itemType = ItemType.DIVIDER_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DividerItem && this == other
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DividerItem && this == other
        }
    }
}
