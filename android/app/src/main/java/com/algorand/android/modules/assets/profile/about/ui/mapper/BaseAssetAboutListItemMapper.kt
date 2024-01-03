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

package com.algorand.android.modules.assets.profile.about.ui.mapper

import androidx.annotation.StringRes
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.browser.createTwitterProfileUrl
import javax.inject.Inject

class BaseAssetAboutListItemMapper @Inject constructor() {

    fun mapToStatisticsItem(
        formattedPriceText: String?,
        formattedCompactTotalSupplyText: String?
    ): BaseAssetAboutListItem.StatisticsItem {
        return BaseAssetAboutListItem.StatisticsItem(
            formattedPriceText = formattedPriceText,
            formattedCompactTotalSupplyText = formattedCompactTotalSupplyText
        )
    }

    fun mapToAboutAssetItem(
        assetName: AssetName,
        assetId: Long?,
        assetCreatorAddress: String?,
        asaUrl: String?,
        displayAsaUrl: String?,
        peraExplorerUrl: String?,
        projectWebsiteUrl: String?
    ): BaseAssetAboutListItem.AboutAssetItem {
        return BaseAssetAboutListItem.AboutAssetItem(
            assetName = assetName,
            assetId = assetId,
            assetCreatorAddress = assetCreatorAddress,
            asaUrl = asaUrl,
            peraExplorerUrl = peraExplorerUrl,
            projectWebsiteUrl = projectWebsiteUrl,
            displayAsaUrl = displayAsaUrl
        )
    }

    fun mapToAssetDescriptionItem(
        descriptionText: String
    ): BaseAssetAboutListItem.BaseAssetDescriptionItem.AssetDescriptionItem {
        return BaseAssetAboutListItem.BaseAssetDescriptionItem.AssetDescriptionItem(descriptionText = descriptionText)
    }

    fun mapToAlgoDescriptionItem(
        @StringRes descriptionTextResId: Int
    ): BaseAssetAboutListItem.BaseAssetDescriptionItem.AlgoDescriptionItem {
        return BaseAssetAboutListItem.BaseAssetDescriptionItem.AlgoDescriptionItem(
            descriptionTextResId = descriptionTextResId
        )
    }

    fun mapToSocialMediaItem(
        discordUrl: String?,
        telegramUrl: String?,
        twitterUsername: String?
    ): BaseAssetAboutListItem.SocialMediaItem {
        return BaseAssetAboutListItem.SocialMediaItem(
            discordUrl = discordUrl,
            telegramUrl = telegramUrl,
            twitterUrl = if (twitterUsername.isNullOrBlank()) null else createTwitterProfileUrl(twitterUsername)
        )
    }

    fun mapToReportItem(assetName: AssetName, assetId: Long): BaseAssetAboutListItem.ReportItem {
        return BaseAssetAboutListItem.ReportItem(assetName = assetName, assetId = assetId)
    }
}
