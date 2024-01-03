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

package com.algorand.android.models

import androidx.annotation.StringRes
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.sorting.assetsorting.ui.model.AssetSortableItem
import com.algorand.android.modules.sorting.nftsorting.ui.model.CollectibleSortableItem
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import java.math.BigDecimal
import java.math.BigInteger

sealed class BaseRemoveAssetItem : RecyclerListItem {

    enum class ItemType {
        REMOVE_ASSET_ITEM,
        REMOVE_COLLECTIBLE_IMAGE_ITEM,
        REMOVE_COLLECTIBLE_VIDEO_ITEM,
        REMOVE_COLLECTIBLE_AUDIO_ITEM,
        REMOVE_COLLECTIBLE_MIXED_ITEM,
        REMOVE_COLLECTIBLE_NOT_SUPPORTED_ITEM,
        SEARCH_VIEW_ITEM,
        TITLE_VIEW_ITEM,
        DESCRIPTION_VIEW_ITEM,
        SCREEN_STATE_ITEM
    }

    abstract val itemType: ItemType

    data class TitleViewItem(
        @StringRes val titleTextRes: Int
    ) : BaseRemoveAssetItem() {

        override val itemType = ItemType.TITLE_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleViewItem && other.titleTextRes == titleTextRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleViewItem && this == other
        }
    }

    data class DescriptionViewItem(
        @StringRes val descriptionTextRes: Int
    ) : BaseRemoveAssetItem() {

        override val itemType = ItemType.DESCRIPTION_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionViewItem && other.descriptionTextRes == descriptionTextRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionViewItem && this == other
        }
    }

    data class SearchViewItem(@StringRes val searchViewHintResId: Int) : BaseRemoveAssetItem() {

        override val itemType: ItemType = ItemType.SEARCH_VIEW_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem && other.searchViewHintResId == searchViewHintResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem && other == this
        }
    }

    data class ScreenStateItem(val screenState: ScreenState) : BaseRemoveAssetItem() {

        override val itemType: ItemType = ItemType.SCREEN_STATE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ScreenStateItem && other.screenState == screenState
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ScreenStateItem && other == this
        }
    }

    sealed class BaseRemovableItem : BaseRemoveAssetItem(), AssetSortableItem {

        abstract val id: Long
        abstract val name: AssetName
        abstract val shortName: AssetName
        abstract val decimals: Int
        abstract val creatorPublicKey: String?
        abstract val amount: BigInteger
        abstract val formattedAmount: String
        abstract val formattedCompactAmount: String
        abstract val formattedSelectedCurrencyValue: String
        abstract val formattedSelectedCurrencyCompactValue: String?
        abstract val baseAssetDrawableProvider: BaseAssetDrawableProvider
        abstract val actionItemButtonState: AccountAssetItemButtonState
        abstract val amountInPrimaryCurrency: BigDecimal?

        data class RemoveAssetItem(
            override val id: Long,
            override val name: AssetName,
            override val shortName: AssetName,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String?,
            override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
            override val actionItemButtonState: AccountAssetItemButtonState,
            val verificationTierConfiguration: VerificationTierConfiguration,
            override val amountInPrimaryCurrency: BigDecimal?
        ) : BaseRemovableItem() {

            override val itemType = ItemType.REMOVE_ASSET_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is RemoveAssetItem && id == other.id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is RemoveAssetItem && this == other
            }

            override val assetSortingNameField: String? = name.getName()
            override val assetSortingBalanceField: BigDecimal? = amountInPrimaryCurrency
        }

        sealed class BaseRemoveCollectibleItem : BaseRemovableItem(), CollectibleSortableItem {

            abstract val optedInAtRound: Long?

            override val collectibleSortingOptedInAtRoundField: Long?
                get() = optedInAtRound

            override val collectibleSortingNameField: String?
                get() = name.getName()

            override val assetSortingNameField: String?
                get() = name.getName()

            override val assetSortingBalanceField: BigDecimal?
                get() = amountInPrimaryCurrency

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is BaseRemoveCollectibleItem && id == other.id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is BaseRemoveCollectibleItem && this == other
            }

            data class RemoveCollectibleImageItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val formattedSelectedCurrencyValue: String,
                override val formattedSelectedCurrencyCompactValue: String?,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val actionItemButtonState: AccountAssetItemButtonState,
                override val optedInAtRound: Long?,
                override val amountInPrimaryCurrency: BigDecimal?,
            ) : BaseRemoveCollectibleItem() {
                override val itemType = ItemType.REMOVE_COLLECTIBLE_IMAGE_ITEM
            }

            data class RemoveCollectibleVideoItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val formattedSelectedCurrencyValue: String,
                override val formattedSelectedCurrencyCompactValue: String?,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val actionItemButtonState: AccountAssetItemButtonState,
                override val optedInAtRound: Long?,
                override val amountInPrimaryCurrency: BigDecimal?,
            ) : BaseRemoveCollectibleItem() {
                override val itemType = ItemType.REMOVE_COLLECTIBLE_VIDEO_ITEM
            }

            data class RemoveCollectibleAudioItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val formattedSelectedCurrencyValue: String,
                override val formattedSelectedCurrencyCompactValue: String,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val actionItemButtonState: AccountAssetItemButtonState,
                override val optedInAtRound: Long?,
                override val amountInPrimaryCurrency: BigDecimal?,
            ) : BaseRemoveCollectibleItem() {
                override val itemType = ItemType.REMOVE_COLLECTIBLE_AUDIO_ITEM
            }

            data class RemoveCollectibleMixedItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val formattedSelectedCurrencyValue: String,
                override val formattedSelectedCurrencyCompactValue: String?,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val actionItemButtonState: AccountAssetItemButtonState,
                override val optedInAtRound: Long?,
                override val amountInPrimaryCurrency: BigDecimal?,
            ) : BaseRemoveCollectibleItem() {
                override val itemType = ItemType.REMOVE_COLLECTIBLE_MIXED_ITEM
            }

            data class RemoveNotSupportedCollectibleItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val formattedSelectedCurrencyValue: String,
                override val formattedSelectedCurrencyCompactValue: String?,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val actionItemButtonState: AccountAssetItemButtonState,
                override val optedInAtRound: Long?,
                override val amountInPrimaryCurrency: BigDecimal?
            ) : BaseRemoveCollectibleItem() {

                override val itemType = ItemType.REMOVE_COLLECTIBLE_NOT_SUPPORTED_ITEM
            }
        }
    }

    companion object {
        val excludedItemFromDivider = listOf(
            ItemType.SEARCH_VIEW_ITEM.ordinal,
            ItemType.TITLE_VIEW_ITEM.ordinal,
            ItemType.DESCRIPTION_VIEW_ITEM.ordinal
        )
    }
}
