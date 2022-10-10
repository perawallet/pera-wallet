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

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.BaseAccountAndAssetListItem
import com.algorand.android.modules.sorting.accountsorting.util.LOCAL_ACCOUNT_START_INDEX

sealed class AccountSortingType {

    enum class TypeIdentifier {
        MANUAL,
        ALPHABETICALLY_ASCENDING,
        ALPHABETICALLY_DESCENDING,
        NUMERIC_ASCENDING,
        NUMERIC_DESCENDING
    }

    abstract val typeIdentifier: TypeIdentifier

    abstract val textResId: Int

    abstract fun sort(
        currentList: List<BaseAccountAndAssetListItem.AccountListItem>
    ): List<BaseAccountAndAssetListItem.AccountListItem>

    object ManuallySort : AccountSortingType() {
        override val typeIdentifier: TypeIdentifier = TypeIdentifier.MANUAL
        override val textResId: Int = R.string.manually

        override fun sort(
            currentList: List<BaseAccountAndAssetListItem.AccountListItem>
        ): List<BaseAccountAndAssetListItem.AccountListItem> {
            return currentList
        }

        fun manualSort(
            currentList: List<BaseAccountAndAssetListItem.AccountListItem>,
            accounts: List<Account>
        ): List<Account> {
            return currentList.mapIndexedNotNull { index, accountSortItem ->
                accounts.firstOrNull { it.address == accountSortItem.itemConfiguration.accountAddress }
                    ?.copy(index = index + LOCAL_ACCOUNT_START_INDEX)
            }
        }
    }

    object AlphabeticallyAscending : AccountSortingType() {
        override val typeIdentifier: TypeIdentifier = TypeIdentifier.ALPHABETICALLY_ASCENDING
        override val textResId: Int = R.string.alphabetically_a_to_z
        override fun sort(
            currentList: List<BaseAccountAndAssetListItem.AccountListItem>
        ): List<BaseAccountAndAssetListItem.AccountListItem> {
            return currentList.sortedBy { it.alphabeticSortingField?.lowercase() }
        }
    }

    object AlphabeticallyDescending : AccountSortingType() {
        override val typeIdentifier: TypeIdentifier = TypeIdentifier.ALPHABETICALLY_DESCENDING
        override val textResId: Int = R.string.alphabetically_z_to_a
        override fun sort(
            currentList: List<BaseAccountAndAssetListItem.AccountListItem>
        ): List<BaseAccountAndAssetListItem.AccountListItem> {
            return currentList.sortedByDescending { it.alphabeticSortingField?.lowercase() }
        }
    }

    object NumericalAscendingSort : AccountSortingType() {
        override val typeIdentifier: TypeIdentifier = TypeIdentifier.NUMERIC_ASCENDING
        override val textResId: Int = R.string.lowest_value_to_highest
        override fun sort(
            currentList: List<BaseAccountAndAssetListItem.AccountListItem>
        ): List<BaseAccountAndAssetListItem.AccountListItem> {
            return currentList.sortedBy { it.numericSortingField }
        }
    }

    object NumericalDescendingSort : AccountSortingType() {
        override val typeIdentifier: TypeIdentifier = TypeIdentifier.NUMERIC_DESCENDING
        override val textResId: Int = R.string.highest_value_to_lowest
        override fun sort(
            currentList: List<BaseAccountAndAssetListItem.AccountListItem>
        ): List<BaseAccountAndAssetListItem.AccountListItem> {
            return currentList.sortedByDescending { it.numericSortingField }
        }
    }

    companion object {
        fun getDefaultSortOption(): AccountSortingType = ManuallySort

        /**
         * Iterates subclasses of BaseAssetSort sealed class and returns the one that
         * matches with typeIdentifier or returns default if can't find.
         * Doesn't work for nested sealed subclasses
         */
        fun getSortTypeByIdentifier(typeIdentifier: TypeIdentifier?): AccountSortingType {
            return AccountSortingType::class.sealedSubclasses.firstOrNull { baseSortingTypeClass ->
                baseSortingTypeClass.objectInstance?.typeIdentifier == typeIdentifier
            }?.objectInstance ?: getDefaultSortOption()
        }
    }
}
