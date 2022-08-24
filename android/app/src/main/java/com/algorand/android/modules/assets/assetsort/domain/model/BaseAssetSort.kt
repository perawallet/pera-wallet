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

package com.algorand.android.modules.assets.assetsort.domain.model

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import java.math.BigDecimal

sealed class BaseAssetSort {

    enum class TypeIdentifier {
        ALPHABETICALLY_ASCENDING,
        ALPHABETICALLY_DESCENDING,
        BALANCE_ASCENDING,
        BALANCE_DESCENDING
    }

    abstract val typeIdentifier: TypeIdentifier

    abstract fun sort(assetList: List<BaseAccountAssetData>): List<BaseAccountAssetData>

    protected fun sortAlphabetically(
        assetList: List<BaseAccountAssetData>,
        sortAction: (List<BaseAccountAssetData>, List<BaseAccountAssetData>) -> List<BaseAccountAssetData>
    ): List<BaseAccountAssetData> {
        val (namedAssets, unnamedAssets) = assetList.partition { !it.name.isNullOrBlank() }
        return sortAction(namedAssets, unnamedAssets)
    }

    protected fun sortByBalance(
        assetList: List<BaseAccountAssetData>,
        sortAction: (
            assetsWithCurrencyValue: List<OwnedAssetData>,
            assetsWithoutCurrencyValue: List<OwnedAssetData>,
            pendingAssets: List<BaseAccountAssetData>
        ) -> List<BaseAccountAssetData>
    ): List<BaseAccountAssetData> {
        val pendingAssets = assetList.filter {
            it is BaseAccountAssetData.PendingAssetData.DeletionAssetData ||
                it is BaseAccountAssetData.PendingAssetData.AdditionAssetData
        }
        val ownedAssets = assetList.filterIsInstance<OwnedAssetData>()
        val (assetsWithCurrencyValue, assetsWithoutCurrencyValue) = ownedAssets.partition {
            it.usdValue != null && it.usdValue != BigDecimal.ZERO
        }
        return sortAction(assetsWithCurrencyValue, assetsWithoutCurrencyValue, pendingAssets)
    }

    object AlphabeticallyAscending : BaseAssetSort() {

        override val typeIdentifier: TypeIdentifier
            get() = TypeIdentifier.ALPHABETICALLY_ASCENDING

        override fun sort(assetList: List<BaseAccountAssetData>): List<BaseAccountAssetData> {
            return sortAlphabetically(assetList) { namedAssets, unnamedAssets ->
                namedAssets.sortedBy { it.name?.lowercase() } + unnamedAssets
            }.sortedByDescending { it is BaseAccountAssetData.PendingAssetData }
        }
    }

    object AlphabeticallyDescending : BaseAssetSort() {

        override val typeIdentifier: TypeIdentifier
            get() = TypeIdentifier.ALPHABETICALLY_DESCENDING

        override fun sort(assetList: List<BaseAccountAssetData>): List<BaseAccountAssetData> {
            return sortAlphabetically(assetList) { namedAssets, unnamedAssets ->
                namedAssets.sortedByDescending { it.name?.lowercase() } + unnamedAssets
            }.sortedByDescending { it is BaseAccountAssetData.PendingAssetData }
        }
    }

    object BalanceAscending : BaseAssetSort() {

        override val typeIdentifier: TypeIdentifier
            get() = TypeIdentifier.BALANCE_ASCENDING

        override fun sort(assetList: List<BaseAccountAssetData>): List<BaseAccountAssetData> {
            return sortByBalance(assetList) { assetsWithCurrencyValue, assetsWithoutCurrencyValue, pendingAssets ->
                pendingAssets +
                    assetsWithoutCurrencyValue.sortedBy { it.amount.toBigDecimal().movePointLeft(it.decimals) } +
                    assetsWithCurrencyValue.sortedBy { it.parityValueInSelectedCurrency.amountAsCurrency }
            }
        }
    }

    object BalanceDescending : BaseAssetSort() {

        override val typeIdentifier: TypeIdentifier
            get() = TypeIdentifier.BALANCE_DESCENDING

        override fun sort(assetList: List<BaseAccountAssetData>): List<BaseAccountAssetData> {
            return sortByBalance(assetList) { assetsWithCurrencyValue, assetsWithoutCurrencyValue, pendingAssets ->
                pendingAssets +
                    assetsWithCurrencyValue.sortedByDescending { it.parityValueInSelectedCurrency.amountAsCurrency } +
                    assetsWithoutCurrencyValue.sortedByDescending {
                        it.amount.toBigDecimal().movePointLeft(it.decimals)
                    }
            }
        }
    }

    companion object {
        fun getDefaultSortOption() = BalanceDescending

        /**
         * Iterates subclasses of BaseAssetSort sealed class and returns the one that
         * matches with typeIdentifier or returns default if can't find.
         * Doesn't work for nested sealed subclasses
         */
        fun getSortTypeByIdentifier(typeIdentifier: TypeIdentifier?): BaseAssetSort {
            return BaseAssetSort::class.sealedSubclasses.firstOrNull { baseAssetSortClass ->
                baseAssetSortClass.objectInstance?.typeIdentifier == typeIdentifier
            }?.objectInstance ?: getDefaultSortOption()
        }
    }
}
