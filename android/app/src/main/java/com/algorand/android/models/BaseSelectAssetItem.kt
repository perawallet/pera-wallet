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

import com.algorand.android.customviews.accountandassetitem.model.BaseItemConfiguration
import com.algorand.android.modules.sorting.assetsorting.ui.model.AssetSortableItem
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import java.math.BigDecimal
import java.math.BigInteger

sealed class BaseSelectAssetItem : RecyclerListItem, AssetSortableItem {

    enum class ItemType {
        SELECT_ASSET_TEM,
        SELECT_COLLECTIBLE_IMAGE_ITEM,
        SELECT_COLLECTIBLE_VIDEO_ITEM,
        SELECT_COLLECTIBLE_AUDIO_ITEM,
        SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM,
        SELECT_COLLECTIBLE_MIXED_ITEM
    }

    abstract val itemType: ItemType

    data class SelectAssetItem(
        val assetItemConfiguration: BaseItemConfiguration.BaseAssetItemConfiguration.AssetItemConfiguration
    ) : BaseSelectAssetItem() {

        override val itemType: ItemType = ItemType.SELECT_ASSET_TEM

        override val assetSortingNameField
            get() = assetItemConfiguration.primaryAssetName?.getName()

        override val assetSortingBalanceField
            get() = assetItemConfiguration.primaryValue

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SelectAssetItem && assetItemConfiguration.assetId == other.assetItemConfiguration.assetId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SelectAssetItem && this == other
        }
    }

    sealed class BaseSelectCollectibleItem : BaseSelectAssetItem() {

        abstract val id: Long
        abstract val name: String?
        abstract val shortName: String?
        abstract val avatarDisplayText: AssetName
        abstract val isAlgo: Boolean
        abstract val amount: BigInteger
        abstract val formattedAmount: String
        abstract val formattedCompactAmount: String
        abstract val formattedSelectedCurrencyValue: String
        abstract val formattedSelectedCurrencyCompactValue: String
        abstract val isAmountInSelectedCurrencyVisible: Boolean
        abstract val baseAssetDrawableProvider: BaseAssetDrawableProvider

        abstract val optedInAtRound: Long?
        abstract val amountInSelectedCurrency: BigDecimal?

        override val assetSortingNameField
            get() = name

        override val assetSortingBalanceField
            get() = amountInSelectedCurrency

        data class SelectCollectibleImageItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
            override val optedInAtRound: Long?,
            override val amountInSelectedCurrency: BigDecimal
        ) : BaseSelectCollectibleItem() {
            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_IMAGE_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectCollectibleImageItem && id == other.id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectCollectibleImageItem && this == other
            }
        }

        data class SelectVideoCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
            override val optedInAtRound: Long?,
            override val amountInSelectedCurrency: BigDecimal
        ) : BaseSelectCollectibleItem() {

            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_VIDEO_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectVideoCollectibleItem && id == other.id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectVideoCollectibleItem && this == other
            }
        }

        data class SelectAudioCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
            override val optedInAtRound: Long?,
            override val amountInSelectedCurrency: BigDecimal
        ) : BaseSelectCollectibleItem() {

            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_AUDIO_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectVideoCollectibleItem && id == other.id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectVideoCollectibleItem && this == other
            }
        }

        data class SelectMixedCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
            override val optedInAtRound: Long?,
            override val amountInSelectedCurrency: BigDecimal
        ) : BaseSelectCollectibleItem() {

            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_MIXED_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectMixedCollectibleItem && id == other.id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectMixedCollectibleItem && this == other
            }
        }

        data class SelectNotSupportedCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
            override val optedInAtRound: Long?,
            override val amountInSelectedCurrency: BigDecimal
        ) : BaseSelectCollectibleItem() {

            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectNotSupportedCollectibleItem && id == other.id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is SelectNotSupportedCollectibleItem && this == other
            }
        }
    }
}
