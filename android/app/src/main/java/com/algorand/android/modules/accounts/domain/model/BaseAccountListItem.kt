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

package com.algorand.android.modules.accounts.domain.model

import androidx.annotation.StringRes
import com.algorand.android.models.BaseAccountAndAssetListItem
import com.algorand.android.models.RecyclerListItem

sealed class BaseAccountListItem : RecyclerListItem {

    abstract val itemType: ItemType

    enum class ItemType {
        ACCOUNT_SUCCESS,
        ACCOUNT_ERROR,
        HEADER,
        QUICK_ACTIONS,
        GOVERNANCE_BANNER,
        GENERIC_BANNER,
        BACKUP_BANNER
    }

    data class QuickActionsItem(
        val isSwapButtonSelected: Boolean
    ) : BaseAccountListItem() {

        override val itemType: ItemType
            get() = ItemType.QUICK_ACTIONS

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is QuickActionsItem && isSwapButtonSelected == other.isSwapButtonSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is QuickActionsItem && other == this
        }
    }

    sealed class BaseBannerItem : BaseAccountListItem() {

        abstract val bannerId: Long

        abstract val buttonText: String?
        abstract val buttonUrl: String?
        abstract val isButtonVisible: Boolean

        abstract val title: String?
        abstract val isTitleVisible: Boolean

        abstract val description: String?
        abstract val isDescriptionVisible: Boolean

        data class GovernanceBannerItem(
            override val bannerId: Long,
            override val buttonText: String?,
            override val buttonUrl: String?,
            override val isButtonVisible: Boolean,
            override val title: String?,
            override val isTitleVisible: Boolean,
            override val description: String?,
            override val isDescriptionVisible: Boolean
        ) : BaseBannerItem() {

            override val itemType: ItemType = ItemType.GOVERNANCE_BANNER

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is GovernanceBannerItem && other.bannerId == bannerId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is GovernanceBannerItem && other == this
            }
        }

        data class GenericBannerItem(
            override val bannerId: Long,
            override val buttonText: String?,
            override val buttonUrl: String?,
            override val isButtonVisible: Boolean,
            override val title: String?,
            override val isTitleVisible: Boolean,
            override val description: String?,
            override val isDescriptionVisible: Boolean
        ) : BaseBannerItem() {

            override val itemType: ItemType = ItemType.GENERIC_BANNER

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is GenericBannerItem && other.bannerId == bannerId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is GenericBannerItem && other == this
            }
        }
    }

    data class BackupBannerItem(
        val accounts: List<String>
    ) : BaseAccountListItem() {

        override val itemType: ItemType = ItemType.BACKUP_BANNER

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is BackupBannerItem
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is BackupBannerItem && other == this
        }
    }

    data class HeaderItem(@StringRes val titleResId: Int) : BaseAccountListItem() {

        override val itemType: ItemType = ItemType.HEADER

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && titleResId == other.titleResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && titleResId == other.titleResId
        }
    }

    sealed class BaseAccountItem : BaseAccountListItem() {

        abstract val accountListItem: BaseAccountAndAssetListItem.AccountListItem
        abstract val canCopyable: Boolean

        data class AccountItem(
            override val accountListItem: BaseAccountAndAssetListItem.AccountListItem,
            override val canCopyable: Boolean
        ) : BaseAccountItem() {

            override val itemType: ItemType = ItemType.ACCOUNT_SUCCESS

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountItem &&
                        other.accountListItem.itemConfiguration.accountAddress ==
                        accountListItem.itemConfiguration.accountAddress &&
                        other.accountListItem.itemConfiguration.primaryValue ==
                        accountListItem.itemConfiguration.primaryValue
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountItem && this == other
            }
        }

        data class AccountErrorItem(
            override val accountListItem: BaseAccountAndAssetListItem.AccountListItem,
            override val canCopyable: Boolean
        ) : BaseAccountItem() {

            override val itemType: ItemType = ItemType.ACCOUNT_ERROR

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountErrorItem &&
                        other.accountListItem.itemConfiguration.accountAddress ==
                        accountListItem.itemConfiguration.accountAddress
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountErrorItem && this == other
            }
        }
    }

    companion object {
        val bannerItemTypes = listOf(
            ItemType.GOVERNANCE_BANNER.ordinal,
            ItemType.GENERIC_BANNER.ordinal,
            ItemType.BACKUP_BANNER.ordinal
        )
    }
}
