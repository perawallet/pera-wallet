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

package com.algorand.android.modules.accountdetail.assets.ui.model

import androidx.annotation.StringRes
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.sorting.assetsorting.ui.model.AssetSortableItem
import com.algorand.android.modules.sorting.core.SortableItemPriority
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.nftindicatordrawable.BaseNFTIndicatorDrawable
import java.math.BigDecimal

sealed class AccountDetailAssetsItem : RecyclerListItem {

    enum class ItemType {
        ACCOUNT_PORTFOLIO,
        ASSETS_LIST_TITLE,
        SEARCH,
        QUICK_ACTIONS,
        ASSET,
        PENDING_ASSET,
        NFT,
        PENDING_NFT,
        NO_ASSET_FOUND,
        REQUIRED_MINIMUM_BALANCE
    }

    abstract val itemType: ItemType

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
        abstract val baseAssetDrawableProvider: BaseAssetDrawableProvider

        sealed class BaseOwnedItem : BaseAssetItem() {

            abstract val formattedAmount: String

            data class AssetItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val formattedAmount: String,
                val verificationTierConfiguration: VerificationTierConfiguration,
                val amountInSelectedCurrency: BigDecimal?,
                val isAmountInDisplayedCurrencyVisible: Boolean,
                val formattedDisplayedCurrencyValue: String
            ) : BaseOwnedItem() {

                override val itemType: ItemType
                    get() = ItemType.ASSET

                override val assetSortingNameField: String?
                    get() = name.getName()

                override val assetSortingBalanceField: BigDecimal
                    get() = amountInSelectedCurrency ?: BigDecimal.ZERO

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is AssetItem && other.id == id
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is AssetItem && other == this
                }
            }

            data class NFTItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                override val formattedAmount: String,
                val collectionName: String?,
                val nftIndicatorDrawable: BaseNFTIndicatorDrawable?,
                val shouldDecreaseOpacity: Boolean,
                val isAmountVisible: Boolean
            ) : BaseOwnedItem() {

                override val itemType: ItemType
                    get() = ItemType.NFT

                override val assetSortingNameField: String?
                    get() = name.getName()

                override val assetSortingBalanceField: BigDecimal
                    get() = BigDecimal.ZERO

                override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                    return other is NFTItem && other.id == id
                }

                override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                    return other is NFTItem && other == this
                }
            }
        }

        sealed class BasePendingItem : BaseAssetItem() {

            override val itemType: ItemType get() = ItemType.PENDING_ASSET
            override val assetSortingNameField: String? get() = name.getName()
            override val assetSortingBalanceField: BigDecimal? get() = null
            override val sortableItemPriority: SortableItemPriority get() = SortableItemPriority.PLACE_FIRST

            abstract val actionDescriptionResId: Int

            sealed class AssetItem : BasePendingItem() {

                abstract val verificationTierConfiguration: VerificationTierConfiguration

                data class AdditionItem(
                    override val id: Long,
                    override val name: AssetName,
                    override val shortName: AssetName,
                    @StringRes override val actionDescriptionResId: Int,
                    override val verificationTierConfiguration: VerificationTierConfiguration,
                    override val baseAssetDrawableProvider: BaseAssetDrawableProvider
                ) : AssetItem() {

                    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                        return other is AdditionItem && other.id == id
                    }

                    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                        return other is AdditionItem && other == this
                    }
                }

                data class RemovalItem(
                    override val id: Long,
                    override val name: AssetName,
                    override val shortName: AssetName,
                    @StringRes override val actionDescriptionResId: Int,
                    override val verificationTierConfiguration: VerificationTierConfiguration,
                    override val baseAssetDrawableProvider: BaseAssetDrawableProvider
                ) : AssetItem() {

                    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                        return other is RemovalItem && other.id == id
                    }

                    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                        return other is RemovalItem && other == this
                    }
                }
            }

            sealed class NFTItem : BasePendingItem() {

                abstract val collectionName: String?

                override val itemType: ItemType
                    get() = ItemType.PENDING_NFT

                data class AdditionItem(
                    override val id: Long,
                    override val name: AssetName,
                    override val shortName: AssetName,
                    override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                    @StringRes override val actionDescriptionResId: Int,
                    override val collectionName: String?
                ) : NFTItem() {

                    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                        return other is AdditionItem && id == other.id
                    }

                    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                        return other is AdditionItem && other == this
                    }
                }

                data class RemovalItem(
                    override val id: Long,
                    override val name: AssetName,
                    override val shortName: AssetName,
                    override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
                    @StringRes override val actionDescriptionResId: Int,
                    override val collectionName: String?
                ) : NFTItem() {

                    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                        return other is RemovalItem && id == other.id
                    }

                    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                        return other is RemovalItem && other == this
                    }
                }
            }
        }
    }

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

    data class RequiredMinimumBalanceItem(
        val formattedRequiredMinimumBalance: String
    ) : AccountDetailAssetsItem() {

        override val itemType: ItemType
            get() = ItemType.REQUIRED_MINIMUM_BALANCE

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is RequiredMinimumBalanceItem &&
                formattedRequiredMinimumBalance == other.formattedRequiredMinimumBalance
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is RequiredMinimumBalanceItem && this == other
        }
    }

    companion object {
        val excludedItemFromDivider = listOf(
            ItemType.ACCOUNT_PORTFOLIO.ordinal,
            ItemType.ASSETS_LIST_TITLE.ordinal,
            ItemType.SEARCH.ordinal,
            ItemType.QUICK_ACTIONS.ordinal,
            ItemType.NO_ASSET_FOUND.ordinal,
            ItemType.REQUIRED_MINIMUM_BALANCE.ordinal
        )
    }
}
