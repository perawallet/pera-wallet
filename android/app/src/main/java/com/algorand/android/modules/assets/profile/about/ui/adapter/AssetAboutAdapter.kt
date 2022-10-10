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

package com.algorand.android.modules.assets.profile.about.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutAboutAssetViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutAlgoDescriptionViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutAssetDescriptionViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutBadgeDescriptionViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutDividerViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutReportViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutSocialMediaViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.AssetAboutStatisticsViewHolder
import com.algorand.android.modules.assets.profile.about.ui.viewholder.BaseAssetAboutAssetDescriptionViewHolder

class AssetAboutAdapter(
    private val listener: AssetAboutListener
) : ListAdapter<BaseAssetAboutListItem, BaseViewHolder<BaseAssetAboutListItem>>(BaseDiffUtil()) {

    private val aboutAssetListener = object : AssetAboutAboutAssetViewHolder.AssetAboutAboutAssetListener {
        override fun onUrlClick(url: String) {
            listener.onUrlClick(url)
        }

        override fun onCreatorAddressClick(creatorAddress: String) {
            listener.onCreatorAddressClick(creatorAddress)
        }

        override fun onCreatorAddressLongClick(creatorAddress: String) {
            listener.onAccountAddressLongClick(creatorAddress)
        }
    }

    private val badgeDescriptionListener = AssetAboutBadgeDescriptionViewHolder.AssetAboutBadgeDescriptionListener {
        listener.onUrlClick(it)
    }

    private val reportListener = AssetAboutReportViewHolder.AssetAboutReportListener { assetId, assetShortName ->
        listener.onReportClick(assetId, assetShortName)
    }

    private val socialMediaListener = AssetAboutSocialMediaViewHolder.AssetAboutSocialMediaListener {
        listener.onUrlClick(it)
    }

    private val statisticsListener = AssetAboutStatisticsViewHolder.AssetAboutStatisticsListener {
        listener.onTotalSupplyInfoClick()
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseAssetAboutListItem> {
        return when (viewType) {
            BaseAssetAboutListItem.ItemType.STATISTICS_ITEM.ordinal -> createStatisticsItem(parent)
            BaseAssetAboutListItem.ItemType.ABOUT_ASSET_ITEM.ordinal -> createAboutAssetItem(parent)
            BaseAssetAboutListItem.ItemType.BADGE_DESCRIPTION_ITEM.ordinal -> createBadgeDescriptionItem(parent)
            BaseAssetAboutListItem.ItemType.ASSET_DESCRIPTION_ITEM.ordinal -> createAssetDescriptionItem(parent)
            BaseAssetAboutListItem.ItemType.ALGO_DESCRIPTION_ITEM.ordinal -> createAlgoDescriptionItem(parent)
            BaseAssetAboutListItem.ItemType.SOCIAL_MEDIA_ITEM.ordinal -> createSocialMediaItem(parent)
            BaseAssetAboutListItem.ItemType.REPORT_ITEM.ordinal -> createReportItem(parent)
            BaseAssetAboutListItem.ItemType.DIVIDER_ITEM.ordinal -> createDividerItem(parent)
            else -> throw Exception("$logTag list item is unknown {$viewType}")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAssetAboutListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createStatisticsItem(parent: ViewGroup): AssetAboutStatisticsViewHolder {
        return AssetAboutStatisticsViewHolder.create(parent, statisticsListener)
    }

    private fun createAboutAssetItem(parent: ViewGroup): AssetAboutAboutAssetViewHolder {
        return AssetAboutAboutAssetViewHolder.create(parent, aboutAssetListener)
    }

    private fun createBadgeDescriptionItem(parent: ViewGroup): AssetAboutBadgeDescriptionViewHolder {
        return AssetAboutBadgeDescriptionViewHolder.create(parent, badgeDescriptionListener)
    }

    private fun createAssetDescriptionItem(parent: ViewGroup): BaseAssetAboutAssetDescriptionViewHolder {
        return AssetAboutAssetDescriptionViewHolder.create(parent)
    }

    private fun createAlgoDescriptionItem(parent: ViewGroup): BaseAssetAboutAssetDescriptionViewHolder {
        return AssetAboutAlgoDescriptionViewHolder.create(parent)
    }

    private fun createSocialMediaItem(parent: ViewGroup): AssetAboutSocialMediaViewHolder {
        return AssetAboutSocialMediaViewHolder.create(parent, socialMediaListener)
    }

    private fun createReportItem(parent: ViewGroup): AssetAboutReportViewHolder {
        return AssetAboutReportViewHolder.create(parent, reportListener)
    }

    private fun createDividerItem(parent: ViewGroup): AssetAboutDividerViewHolder {
        return AssetAboutDividerViewHolder.create(parent)
    }

    interface AssetAboutListener {
        fun onUrlClick(url: String)
        fun onReportClick(assetId: Long, assetShortName: String)
        fun onTotalSupplyInfoClick()
        fun onCreatorAddressClick(creatorAddress: String)
        fun onAccountAddressLongClick(accountAddress: String)
    }

    companion object {
        private val logTag = AssetAboutAdapter::class.simpleName
    }
}
