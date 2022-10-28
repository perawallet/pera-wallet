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

sealed class BaseCollectibleListItem : RecyclerListItem, CollectibleSortableItem {

    enum class ItemType {
        TITLE_TEXT_VIEW_ITEM,
        SEARCH_VIEW_ITEM,
        INFO_VIEW_ITEM,
        RECEIVE_ITEM,
        GIF_ITEM,
        VIDEO_ITEM,
        IMAGE_ITEM,
        MIXED_ITEM,
        SOUND_ITEM,
        NOT_SUPPORTED_ITEM,
        PENDING_ADDITION_ITEM,
        PENDING_REMOVAL_ITEM,
        PENDING_SENDING_ITEM
    }

    abstract val itemType: ItemType

    override val collectibleSortingOptedInAtRoundField: Long?
        get() = null
    override val collectibleSortingNameField: String?
        get() = null

    data class TitleTextViewItem(val isVisible: Boolean) : BaseCollectibleListItem() {

        override val itemType: ItemType = ItemType.TITLE_TEXT_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleTextViewItem && other.isVisible == isVisible
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleTextViewItem
        }
    }

    data class InfoViewItem(
        val displayedCollectibleCount: Int,
        val isVisible: Boolean, // TODO: We should create an instance if it's not visible
        val isFilterActive: Boolean,
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
        val isVisible: Boolean, // TODO: We should create an instance if it's not visible
        val query: String
    ) : BaseCollectibleListItem() {

        override val itemType: ItemType = ItemType.SEARCH_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem && other.searchViewHintResId == searchViewHintResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem &&
                other.searchViewHintResId == searchViewHintResId &&
                other.isVisible == isVisible
        }
    }

    object ReceiveNftItem : BaseCollectibleListItem() {

        override val itemType: ItemType = ItemType.RECEIVE_ITEM

        override val sortableItemPriority: SortableItemPriority
            get() = SortableItemPriority.PLACE_LAST

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ReceiveNftItem
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ReceiveNftItem
        }
    }

    sealed class BaseCollectibleItem : BaseCollectibleListItem() {

        abstract val collectibleId: Long
        abstract val collectibleName: String?
        abstract val collectionName: String?
        abstract val isOwnedByTheUser: Boolean
        abstract val avatarDisplayText: String
        abstract val badgeImageResId: Int?
        abstract val optedInAccountAddress: String
        abstract val optedInAtRound: Long?
        abstract val isAmountVisible: Boolean
        abstract val formattedCollectibleAmount: String?

        override val collectibleSortingNameField: String?
            get() = collectibleName
        override val collectibleSortingOptedInAtRoundField: Long?
            get() = optedInAtRound

        data class CollectibleGifItem(
            override val collectibleId: Long,
            override val collectibleName: String?,
            override val collectionName: String?,
            override val isOwnedByTheUser: Boolean,
            override val avatarDisplayText: String,
            override val badgeImageResId: Int?,
            override val optedInAccountAddress: String,
            override val optedInAtRound: Long?,
            override val formattedCollectibleAmount: String,
            override val isAmountVisible: Boolean
        ) : BaseCollectibleItem() {

            override val itemType: ItemType = ItemType.GIF_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleGifItem && other.collectibleId == collectibleId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleGifItem && other == this
            }
        }

        data class CollectibleVideoItem(
            override val collectibleId: Long,
            override val collectibleName: String?,
            override val collectionName: String?,
            override val isOwnedByTheUser: Boolean,
            override val avatarDisplayText: String,
            override val badgeImageResId: Int?,
            override val optedInAccountAddress: String,
            override val optedInAtRound: Long?,
            override val formattedCollectibleAmount: String,
            val thumbnailPrismUrl: String?,
            override val isAmountVisible: Boolean
        ) : BaseCollectibleItem() {

            override val itemType: ItemType = ItemType.VIDEO_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleVideoItem && other.collectibleId == collectibleId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleVideoItem && other == this
            }
        }

        data class CollectibleImageItem(
            override val collectibleId: Long,
            override val collectibleName: String?,
            override val collectionName: String?,
            override val isOwnedByTheUser: Boolean,
            override val avatarDisplayText: String,
            override val badgeImageResId: Int?,
            override val optedInAccountAddress: String,
            override val optedInAtRound: Long?,
            override val formattedCollectibleAmount: String,
            val prismUrl: String?,
            override val isAmountVisible: Boolean
        ) : BaseCollectibleItem() {

            override val itemType: ItemType = ItemType.IMAGE_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleImageItem && other.collectibleId == collectibleId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleImageItem && other == this
            }
        }

        data class CollectibleMixedItem(
            override val collectibleId: Long,
            override val collectibleName: String?,
            override val collectionName: String?,
            override val isOwnedByTheUser: Boolean,
            override val avatarDisplayText: String,
            override val badgeImageResId: Int?,
            override val optedInAccountAddress: String,
            override val optedInAtRound: Long?,
            override val formattedCollectibleAmount: String,
            override val isAmountVisible: Boolean,
            val thumbnailPrismUrl: String?
        ) : BaseCollectibleItem() {

            override val itemType: ItemType = ItemType.MIXED_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleImageItem && other.collectibleId == collectibleId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleImageItem && other == this
            }
        }

        data class CollectibleSoundItem(
            override val collectibleId: Long,
            override val collectibleName: String?,
            override val collectionName: String?,
            override val isOwnedByTheUser: Boolean,
            override val avatarDisplayText: String,
            override val badgeImageResId: Int?,
            override val optedInAccountAddress: String,
            override val optedInAtRound: Long?,
            override val formattedCollectibleAmount: String,
            override val isAmountVisible: Boolean
        ) : BaseCollectibleItem() {

            override val itemType: ItemType = ItemType.SOUND_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleSoundItem && other.collectibleId == collectibleId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is CollectibleSoundItem && other == this
            }
        }

        data class NotSupportedCollectibleItem(
            override val collectibleId: Long,
            override val collectibleName: String?,
            override val collectionName: String?,
            override val isOwnedByTheUser: Boolean,
            override val avatarDisplayText: String,
            override val badgeImageResId: Int?,
            override val optedInAccountAddress: String,
            override val optedInAtRound: Long?,
            override val formattedCollectibleAmount: String,
            override val isAmountVisible: Boolean
        ) : BaseCollectibleItem() {

            override val itemType: ItemType = ItemType.NOT_SUPPORTED_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is NotSupportedCollectibleItem && other.collectibleId == collectibleId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is NotSupportedCollectibleItem && other == this
            }
        }

        sealed class BasePendingCollectibleItem : BaseCollectibleItem() {

            abstract val primaryImageUrl: String?

            val actionDescriptionResId: Int = R.string.pending

            override val sortableItemPriority: SortableItemPriority
                get() = SortableItemPriority.PLACE_FIRST

            override val isAmountVisible: Boolean = false
            override val formattedCollectibleAmount: String? = null

            data class PendingAdditionItem(
                override val collectibleId: Long,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val isOwnedByTheUser: Boolean,
                override val avatarDisplayText: String,
                override val primaryImageUrl: String?,
                override val badgeImageResId: Int?,
                override val optedInAccountAddress: String,
                override val optedInAtRound: Long?
            ) : BasePendingCollectibleItem() {

                override val itemType: ItemType = ItemType.PENDING_ADDITION_ITEM

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingAdditionItem && collectibleId == other.collectibleId
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingAdditionItem && this == other
                }
            }

            data class PendingRemovalItem(
                override val collectibleId: Long,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val isOwnedByTheUser: Boolean,
                override val avatarDisplayText: String,
                override val primaryImageUrl: String?,
                override val badgeImageResId: Int?,
                override val optedInAccountAddress: String,
                override val optedInAtRound: Long?
            ) : BasePendingCollectibleItem() {

                override val itemType: ItemType = ItemType.PENDING_REMOVAL_ITEM

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingRemovalItem && collectibleId == other.collectibleId
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingRemovalItem && this == other
                }
            }

            data class PendingSendingItem(
                override val collectibleId: Long,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val isOwnedByTheUser: Boolean,
                override val avatarDisplayText: String,
                override val primaryImageUrl: String?,
                override val badgeImageResId: Int?,
                override val optedInAccountAddress: String,
                override val optedInAtRound: Long?
            ) : BasePendingCollectibleItem() {

                override val itemType: ItemType = ItemType.PENDING_SENDING_ITEM

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingSendingItem && collectibleId == other.collectibleId
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingSendingItem && this == other
                }
            }
        }
    }
}
