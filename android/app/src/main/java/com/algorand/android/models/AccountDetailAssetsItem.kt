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
import com.algorand.android.utils.AssetName
import kotlinx.parcelize.Parcelize

sealed class AccountDetailAssetsItem : RecyclerListItem, Parcelable {

    @Parcelize
    data class AccountValueItem(val accountValue: String?) : AccountDetailAssetsItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountValueItem && accountValue == other.accountValue
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountValueItem && this == other
        }
    }

    @Parcelize
    data class TitleItem(@StringRes val titleRes: Int) : AccountDetailAssetsItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && titleRes == other.titleRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && this == other
        }
    }

    @Parcelize
    object SearchViewItem : AccountDetailAssetsItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem && this == other
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is SearchViewItem && this == other
        }
    }

    sealed class BaseAssetItem : AccountDetailAssetsItem() {
        abstract val id: Long
        abstract val name: AssetName
        abstract val shortName: AssetName
        abstract val isVerified: Boolean
        abstract val isAlgo: Boolean
        abstract val isAmountInSelectedCurrencyVisible: Boolean

        @Parcelize
        data class OwnedAssetItem(
            override val id: Long,
            override val name: AssetName,
            override val shortName: AssetName,
            override val isAlgo: Boolean,
            override val isVerified: Boolean,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            val formattedSelectedCurrencyValue: String,
            val formattedAmount: String
        ) : BaseAssetItem() {

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is OwnedAssetItem && other.id == id
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is OwnedAssetItem && other == this
            }
        }

        sealed class BasePendingAssetItem : BaseAssetItem() {

            abstract val actionDescriptionResId: Int

            @Parcelize
            data class PendingAdditionItem(
                override val id: Long,
                override val name: AssetName,
                override val shortName: AssetName,
                override val isVerified: Boolean,
                override val isAlgo: Boolean,
                @StringRes override val actionDescriptionResId: Int
            ) : BasePendingAssetItem() {

                override val isAmountInSelectedCurrencyVisible: Boolean
                    get() = false

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
                override val isVerified: Boolean,
                override val isAlgo: Boolean,
                @StringRes override val actionDescriptionResId: Int
            ) : BasePendingAssetItem() {

                override val isAmountInSelectedCurrencyVisible: Boolean
                    get() = false

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
    object AssetAdditionItem : AccountDetailAssetsItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetAdditionItem && this == other
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetAdditionItem && this == other
        }
    }
}
