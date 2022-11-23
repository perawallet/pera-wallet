/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models

import android.os.Parcelable
import androidx.annotation.StringRes
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.modules.sorting.assetsorting.ui.model.AssetSortableItem
import com.algorand.android.modules.sorting.core.SortableItemPriority
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import java.math.BigDecimal
import kotlinx.parcelize.Parcelize

sealed class AccountDetailAssetsItem : RecyclerListItem, Parcelable {

    enum class ItemType {
        ACCOUNT_PORTFOLIO,
        ASSETS_LIST_TITLE,
        SEARCH,
        QUICK_ACTIONS,
        ASSET,
        PENDING_ASSET,
        NO_ASSET_FOUND
    }

    abstract val itemType: ItemType

    @Parcelize
    data class AccountPortfolioItem(
        val accountPrimaryFormattedParityValue: String?,
        val accountSecondaryFormattedParityValue: String?
    ) : AccountDetailAssetsItem() {

        override val itemType: ItemType
            get() = ItemType.ACCOUNT_PORTFOLIO

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountPortfolioItem &&
                accountPrimaryFormattedParityValue == other.accountPrimaryFormattedParityValue
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountPortfolioItem && this == other
        }
    }

    @Parcelize
    data class TitleItem(
        @StringRes val titleRes: Int,
        val isAddAssetButtonVisible: Boolean
    ) : AccountDetailAssetsItem() {

        override val itemType: ItemType
            get() = ItemType.ASSETS_LIST_TITLE

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && titleRes == other.titleRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && this == other
        }
    }

    @Parcelize
    data class SearchViewItem(val query: String) : AccountDetailAssetsItem() {

        override val itemType: ItemType
            get() = ItemType.SEARCH

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem
        }
    }

    @Parcelize
    data class QuickActionsItem(
        val isSwapButtonSelected: Boolean
    ) : AccountDetailAssetsItem() {

        override val itemType: ItemType
            get() = ItemType.QUICK_ACTIONS

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is QuickActionsItem && isSwapButtonSelected == other.isSwapButtonSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is QuickActionsItem && this == other
        }
    }

    sealed class BaseAssetItem : AccountDetailAssetsItem(), AssetSortableItem {
        abstract val id: Long
        abstract val name: AssetName
        abstract val shortName: AssetName
        abstract val isAmountInDisplayedCurrencyVisible: Boolean
        abstract val verificationTierConfiguration: VerificationTierConfiguration
        abstract val baseAssetDrawableProvider: BaseAssetDrawableProvider

        // TODO: Move this under [OwnedAssetItem]
        override val itemType: ItemType
            get() = ItemType.ASSET

        @Parcelize
        data class OwnedAssetItem(
            override val id: Long,
            override val name: AssetName,
            override val shortName: AssetName,
            override val isAmountInDisplayedCurrencyVisible: Boolean,
            override val verificationTierConfiguration: VerificationTierConfiguration,
            override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
            val formattedDisplayedCurrencyValue: String,
            val formattedAmount: String,
            val prismUrl: String?,
            val amountInSelectedCurrency: BigDecimal?
        ) : BaseAssetItem() {

            override val assetSortingNameField: String?
                get() = name.getName()
            override val assetSortingBalanceField: BigDecimal
                get() = amountInSelectedCurrency ?: BigDecimal.ZERO

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is OwnedAssetItem && other.id == id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is OwnedAssetItem && other == this
            }
        }

        sealed class BasePendingAssetItem : BaseAssetItem() {

            abstract val actionDescriptionResId: Int

            override val itemType: ItemType
                get() = ItemType.PENDING_ASSET

            @Parcelize
            data class PendingAdditionItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                @StringRes override val actionDescriptionResId: Int,
                override val verificationTierConfiguration: VerificationTierConfiguration,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider
            ) : BasePendingAssetItem() {

                override val isAmountInDisplayedCurrencyVisible: Boolean
                    get() = false

                override val assetSortingNameField: String?
                    get() = name.getName()
                override val assetSortingBalanceField: BigDecimal?
                    get() = null
                override val sortableItemPriority: SortableItemPriority
                    get() = SortableItemPriority.PLACE_FIRST

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingAdditionItem && other.id == id
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingAdditionItem && other == this
                }
            }

            @Parcelize
            data class PendingRemovalItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                @StringRes override val actionDescriptionResId: Int,
                override val verificationTierConfiguration: VerificationTierConfiguration,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider
            ) : BasePendingAssetItem() {

                override val isAmountInDisplayedCurrencyVisible: Boolean
                    get() = false

                override val assetSortingNameField: String?
                    get() = name.getName()
                override val assetSortingBalanceField: BigDecimal?
                    get() = null
                override val sortableItemPriority: SortableItemPriority
                    get() = SortableItemPriority.PLACE_FIRST

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingRemovalItem && other.id == id
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is PendingRemovalItem && other == this
                }
            }
        }
    }

    @Parcelize
    object NoAssetFoundViewItem : AccountDetailAssetsItem() {

        override val itemType: ItemType
            get() = ItemType.NO_ASSET_FOUND

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is NoAssetFoundViewItem
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is NoAssetFoundViewItem
        }
    }
}
