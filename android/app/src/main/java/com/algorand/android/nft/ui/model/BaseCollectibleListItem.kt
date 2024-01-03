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

package com.algorand.android.nft.ui.model

import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.sorting.core.SortableItemPriority
import com.algorand.android.modules.sorting.nftsorting.ui.model.CollectibleSortableItem
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.Event
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.nftindicatordrawable.BaseNFTIndicatorDrawable

sealed class BaseCollectibleListItem : RecyclerListItem, CollectibleSortableItem {

    enum class ItemType {
        TITLE_TEXT_VIEW_ITEM,
        SEARCH_VIEW_ITEM,
        INFO_VIEW_ITEM,
        LINEAR_VERTICAL_SIMPLE_NFT_ITEM,
        LINEAR_VERTICAL_SIMPLE_PENDING_ITEM,
        GRID_SIMPLE_NFT_ITEM,
        GRID_SIMPLE_PENDING_ITEM,
    }

    abstract val itemType: ItemType

    override val collectibleSortingOptedInAtRoundField: Long? = null
    override val collectibleSortingNameField: String? = null

    object TitleTextViewItem : BaseCollectibleListItem() {

        override val itemType: ItemType = ItemType.TITLE_TEXT_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleTextViewItem && this == other
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleTextViewItem
        }
    }

    data class InfoViewItem(
        val displayedCollectibleCount: Int,
        val isAddButtonVisible: Boolean
    ) : BaseCollectibleListItem() {

        override val itemType: ItemType = ItemType.INFO_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is InfoViewItem && other.displayedCollectibleCount == displayedCollectibleCount
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is InfoViewItem && other == this
        }
    }

    data class SearchViewItem(
        @StringRes val searchViewHintResId: Int,
        val query: String,
        val onGridListViewSelectedEvent: Event<Unit>? = null,
        val onLinearListViewSelectedEvent: Event<Unit>? = null
    ) : BaseCollectibleListItem() {

        override val itemType: ItemType = ItemType.SEARCH_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem && other.searchViewHintResId == searchViewHintResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem && other.searchViewHintResId == searchViewHintResId
        }
    }

    sealed class BaseCollectibleItem : BaseCollectibleListItem() {

        abstract val collectibleId: Long
        abstract val collectibleName: AssetName?
        abstract val collectionName: String?
        abstract val optedInAccountAddress: String
        abstract val optedInAtRound: Long?
        abstract val isAmountVisible: Boolean
        abstract val formattedCollectibleAmount: String?
        abstract val baseAssetDrawableProvider: BaseAssetDrawableProvider
        abstract val nftIndicatorDrawable: BaseNFTIndicatorDrawable?
        abstract val shouldDecreaseOpacity: Boolean

        sealed class BaseOwnedNFTItem : BaseCollectibleItem() {

            override val collectibleSortingNameField: String?
                get() = collectibleName?.getName()

            override val collectibleSortingOptedInAtRoundField: Long?
                get() = optedInAtRound

            data class SimpleNFTItem(
                override val collectibleId: Long,
                override val collectibleName: AssetName?,
                override val collectionName: String?,
                override val optedInAccountAddress: String,
                override val optedInAtRound: Long?,
                override val formattedCollectibleAmount: String,
                override val isAmountVisible: Boolean,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val itemType: ItemType,
                override val nftIndicatorDrawable: BaseNFTIndicatorDrawable?,
                override val shouldDecreaseOpacity: Boolean
            ) : BaseOwnedNFTItem() {

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is SimpleNFTItem && other.collectibleId == collectibleId
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is SimpleNFTItem && other == this
                }
            }
        }

        sealed class BasePendingNFTItem : BaseCollectibleItem() {

            val actionDescriptionResId: Int = R.string.pending
            override val sortableItemPriority: SortableItemPriority = SortableItemPriority.PLACE_FIRST
            override val isAmountVisible: Boolean = false
            override val formattedCollectibleAmount: String? = null
            override val nftIndicatorDrawable: BaseNFTIndicatorDrawable? = null
            override val shouldDecreaseOpacity: Boolean = false

            data class SimplePendingNFTItem(
                override val collectibleId: Long,
                override val collectibleName: AssetName?,
                override val collectionName: String?,
                override val optedInAccountAddress: String,
                override val optedInAtRound: Long?,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val itemType: ItemType
            ) : BasePendingNFTItem() {

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is SimplePendingNFTItem && collectibleId == other.collectibleId
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is SimplePendingNFTItem && this == other
                }
            }
        }
    }

    companion object {
        val singleColumnItemList = listOf(
            ItemType.GRID_SIMPLE_NFT_ITEM.ordinal,
            ItemType.GRID_SIMPLE_PENDING_ITEM.ordinal
        )
        val excludedItemFromDivider = listOf(
            ItemType.TITLE_TEXT_VIEW_ITEM.ordinal,
            ItemType.SEARCH_VIEW_ITEM.ordinal,
            ItemType.INFO_VIEW_ITEM.ordinal,
            ItemType.GRID_SIMPLE_NFT_ITEM.ordinal,
            ItemType.GRID_SIMPLE_PENDING_ITEM.ordinal
        )
    }
}
