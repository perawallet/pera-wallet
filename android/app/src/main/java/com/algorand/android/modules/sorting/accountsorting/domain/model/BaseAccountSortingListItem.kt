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

package com.algorand.android.modules.sorting.accountsorting.domain.model

import androidx.annotation.StringRes
import com.algorand.android.models.BaseAccountAndAssetListItem
import com.algorand.android.models.RecyclerListItem

sealed class BaseAccountSortingListItem : RecyclerListItem {

    enum class ItemType {
        SORTING_TYPE,
        HEADER,
        ACCOUNT_SORT
    }

    abstract val itemType: ItemType

    data class SortTypeListItem(
        val accountSortingType: AccountSortingType,
        var isChecked: Boolean
    ) : BaseAccountSortingListItem() {

        override val itemType: ItemType = ItemType.SORTING_TYPE

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SortTypeListItem &&
                accountSortingType == other.accountSortingType &&
                isChecked == other.isChecked
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SortTypeListItem && this == other
        }
    }

    data class HeaderListItem(@StringRes val headerTextResId: Int) : BaseAccountSortingListItem() {

        override val itemType: ItemType = ItemType.HEADER

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderListItem && headerTextResId == other.headerTextResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderListItem && this == other
        }
    }

    data class AccountSortListItem(
        val accountListItem: BaseAccountAndAssetListItem.AccountListItem
    ) : BaseAccountSortingListItem() {

        override val itemType: ItemType = ItemType.ACCOUNT_SORT

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountSortListItem &&
                other.accountListItem.itemConfiguration.accountAddress ==
                accountListItem.itemConfiguration.accountAddress
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountSortListItem && this == other
        }
    }
}
