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

package com.algorand.android.nft.ui.nftlisting

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.GRID_SIMPLE_NFT_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.GRID_SIMPLE_PENDING_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.INFO_VIEW_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.LINEAR_VERTICAL_SIMPLE_NFT_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.LINEAR_VERTICAL_SIMPLE_PENDING_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.SEARCH_VIEW_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.TITLE_TEXT_VIEW_ITEM
import com.algorand.android.nft.ui.nftlisting.viewholder.InfoItemViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.InfoItemViewHolder.InfoItemListener
import com.algorand.android.nft.ui.nftlisting.viewholder.OwnedNFTGridViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.OwnedNFTLinearVerticalViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.PendingNFTGridViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.PendingNFTLinearVerticalViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.SearchViewItemViewHolder
import com.algorand.android.nft.ui.nftlisting.viewholder.TitleTextItemViewHolder
import com.algorand.android.nft.utils.NFTItemClickListener
import com.algorand.android.utils.hideKeyboard

class CollectibleListAdapter(
    private val listener: CollectibleListAdapterListener
) : ListAdapter<BaseCollectibleListItem, BaseViewHolder<BaseCollectibleListItem>>(
    BaseDiffUtil<BaseCollectibleListItem>()
) {

    private val infoItemListener = object : InfoItemListener {
        override fun primaryButtonOnClickListener() = listener.onManageCollectiblesClick()
        override fun secondaryButtonClickListener() = listener.onReceiveCollectibleItemClick()
    }

    private val searchViewTextChangedListener = object : SearchViewItemViewHolder.Listener {
        override fun onSearchViewTextChanged(text: String) {
            listener.onSearchQueryUpdated(text)
        }

        override fun onLinearVerticalListingOptionSelected() {
            listener.onLinearVerticalListingOptionSelected()
        }

        override fun onGridListingOptionSelected() {
            listener.onGridListingOptionSelected()
        }
    }

    private val ownedNFTClickItemListener = NFTItemClickListener { nftId, nftOwnerId ->
        listener.onOwnedNFTItemClick(nftId, nftOwnerId)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseCollectibleListItem> {
        return when (viewType) {
            TITLE_TEXT_VIEW_ITEM.ordinal -> createTitleViewHolder(parent)
            INFO_VIEW_ITEM.ordinal -> createInfoViewHolder(parent)
            SEARCH_VIEW_ITEM.ordinal -> createSearchViewHolder(parent)
            LINEAR_VERTICAL_SIMPLE_NFT_ITEM.ordinal -> createLinearVerticalSimpleNFTViewHolder(parent)
            LINEAR_VERTICAL_SIMPLE_PENDING_ITEM.ordinal -> createLinearVerticalSimplePendingNFTViewHolder(parent)
            GRID_SIMPLE_NFT_ITEM.ordinal -> createGridSimpleNFTViewHolder(parent)
            GRID_SIMPLE_PENDING_ITEM.ordinal -> createGridSimplePendingNFTViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag: Unknown Item Type -> $viewType")
        }
    }

    private fun createTitleViewHolder(parent: ViewGroup): BaseViewHolder<BaseCollectibleListItem> {
        return TitleTextItemViewHolder.create(parent)
    }

    private fun createInfoViewHolder(parent: ViewGroup): BaseViewHolder<BaseCollectibleListItem> {
        return InfoItemViewHolder.create(parent, infoItemListener = infoItemListener)
    }

    private fun createSearchViewHolder(parent: ViewGroup): BaseViewHolder<BaseCollectibleListItem> {
        return SearchViewItemViewHolder.create(parent, listener = searchViewTextChangedListener)
    }

    private fun createLinearVerticalSimpleNFTViewHolder(
        parent: ViewGroup
    ): BaseViewHolder<BaseCollectibleListItem> {
        return OwnedNFTLinearVerticalViewHolder.create(parent, ownedNFTClickItemListener)
    }

    private fun createLinearVerticalSimplePendingNFTViewHolder(
        parent: ViewGroup
    ): BaseViewHolder<BaseCollectibleListItem> {
        return PendingNFTLinearVerticalViewHolder.create(parent)
    }

    private fun createGridSimpleNFTViewHolder(parent: ViewGroup): BaseViewHolder<BaseCollectibleListItem> {
        return OwnedNFTGridViewHolder.create(parent, ownedNFTClickItemListener)
    }

    private fun createGridSimplePendingNFTViewHolder(parent: ViewGroup): BaseViewHolder<BaseCollectibleListItem> {
        return PendingNFTGridViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseCollectibleListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    override fun onViewDetachedFromWindow(holder: BaseViewHolder<BaseCollectibleListItem>) {
        super.onViewDetachedFromWindow(holder)
        if (holder is SearchViewItemViewHolder) {
            holder.itemView.hideKeyboard()
        }
    }

    interface CollectibleListAdapterListener {
        fun onOwnedNFTItemClick(collectibleAssetId: Long, publicKey: String)
        fun onReceiveCollectibleItemClick()
        fun onSearchQueryUpdated(query: String)
        fun onManageCollectiblesClick()
        fun onLinearVerticalListingOptionSelected()
        fun onGridListingOptionSelected()
    }

    companion object {
        private val logTag = CollectibleListAdapter::class.java.simpleName
    }
}
