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

package com.algorand.android.modules.assets.addition.ui.adapter

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.AssetListItem.AssetSearchItem
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.ASSET_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_IMAGE_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_MIXED_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_NOT_SUPPORTED_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.COLLECTIBLE_VIDEO_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.INFO_VIEW_ITEM
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem.ItemType.SEARCH_VIEW_ITEM
import com.algorand.android.assetsearch.ui.viewholder.BaseCollectibleSearchItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchImageItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchMixedItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchNotSupportedItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.CollectibleSearchVideoItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.InfoViewItemViewHolder
import com.algorand.android.assetsearch.ui.viewholder.SearchViewItemViewHolder
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.utils.hideKeyboard

class AssetSearchAdapter(
    private val listener: AssetSearchAdapterListener
) : PagingDataAdapter<BaseAssetSearchListItem, BaseViewHolder<BaseAssetSearchListItem>>(BaseDiffUtil()) {

    private val searchViewTextChangedListener = SearchViewItemViewHolder.SearchViewTextChangedListener { query ->
        listener.onSearchQueryUpdated(query)
    }

    private val assetSearchItemListener = object : AssetSearchItemViewHolder.AssetSearchItemListener {
        override fun onAssetItemClick(assetId: Long) {
            listener.onNavigateToAssetDetail(assetId)
        }

        override fun onAssetItemActionButtonClick(assetSearchItem: AssetSearchItem) {
            listener.onAddAssetClick(assetSearchItem)
        }
    }

    private val collectibleSearchItemListener = object : BaseCollectibleSearchItemViewHolder
    .CollectibleSearchItemListener {
        override fun onCollectibleItemClick(collectibleId: Long) {
            listener.onNavigateToCollectibleDetail(collectibleId)
        }

        override fun onCollectibleItemActionButtonClick(
            assetSearchItem: BaseAssetSearchListItem.AssetListItem.BaseCollectibleSearchListItem
        ) {
            listener.onAddAssetClick(assetSearchItem)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position)?.itemType?.ordinal ?: RecyclerView.NO_POSITION
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseAssetSearchListItem> {
        return when (viewType) {
            INFO_VIEW_ITEM.ordinal -> createInfoViewItemViewHolder(parent)
            SEARCH_VIEW_ITEM.ordinal -> createSearchViewItemViewHolder(parent)
            ASSET_ITEM.ordinal -> createAssetSearchItemViewHolder(parent)
            COLLECTIBLE_IMAGE_ITEM.ordinal -> createImageItemImageViewHolder(parent)
            COLLECTIBLE_NOT_SUPPORTED_ITEM.ordinal -> createNotSupportedItemViewHolder(parent)
            COLLECTIBLE_VIDEO_ITEM.ordinal -> createVideoItemViewHolder(parent)
            COLLECTIBLE_MIXED_ITEM.ordinal -> createMixedItemViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag: Unknown viewType = $viewType")
        }
    }

    override fun onViewDetachedFromWindow(holder: BaseViewHolder<BaseAssetSearchListItem>) {
        super.onViewDetachedFromWindow(holder)
        if (holder is SearchViewItemViewHolder) {
            holder.itemView.hideKeyboard()
        }
    }

    private fun createInfoViewItemViewHolder(parent: ViewGroup): InfoViewItemViewHolder {
        return InfoViewItemViewHolder.create(parent)
    }

    private fun createSearchViewItemViewHolder(parent: ViewGroup): SearchViewItemViewHolder {
        return SearchViewItemViewHolder.create(parent, searchViewTextChangedListener = searchViewTextChangedListener)
    }

    private fun createAssetSearchItemViewHolder(parent: ViewGroup): AssetSearchItemViewHolder {
        return AssetSearchItemViewHolder.create(parent, assetSearchItemListener)
    }

    private fun createImageItemImageViewHolder(parent: ViewGroup): CollectibleSearchImageItemViewHolder {
        return CollectibleSearchImageItemViewHolder.create(parent, collectibleSearchItemListener)
    }

    private fun createVideoItemViewHolder(parent: ViewGroup): CollectibleSearchVideoItemViewHolder {
        return CollectibleSearchVideoItemViewHolder.create(parent, collectibleSearchItemListener)
    }

    private fun createMixedItemViewHolder(parent: ViewGroup): CollectibleSearchMixedItemViewHolder {
        return CollectibleSearchMixedItemViewHolder.create(parent, collectibleSearchItemListener)
    }

    private fun createNotSupportedItemViewHolder(parent: ViewGroup): CollectibleSearchNotSupportedItemViewHolder {
        return CollectibleSearchNotSupportedItemViewHolder.create(parent, collectibleSearchItemListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAssetSearchListItem>, position: Int) {
        getItem(position)?.let { assetQueryItem ->
            holder.bind(assetQueryItem)
        }
    }

    interface AssetSearchAdapterListener {
        fun onAddAssetClick(assetSearchItem: BaseAssetSearchListItem.AssetListItem)
        fun onNavigateToAssetDetail(assetId: Long)
        fun onNavigateToCollectibleDetail(collectibleId: Long)
        fun onSearchQueryUpdated(query: String)
    }

    companion object {
        private val logTag = AssetSearchAdapter::class.java.simpleName
    }
}
