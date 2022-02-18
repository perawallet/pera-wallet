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

package com.algorand.android.ui.common.listhelper

import androidx.annotation.ColorRes
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.RecyclerListItem

sealed class BaseAccountListItem : RecyclerListItem {

    abstract val itemType: ItemType

    enum class ItemType {
        PORTFOLIO_SUCCESS,
        PORTFOLIO_ERROR,
        ACCOUNT_SUCCESS,
        ACCOUNT_ERROR,
        HEADER
    }

    sealed class BasePortfolioValueItem : BaseAccountListItem() {

        open val errorStringResId: Int? = null

        data class PortfolioValuesItem(
            val formattedPortfolioValue: String,
            val formattedAlgoHoldings: String,
            val formattedAssetHoldings: String
        ) : BasePortfolioValueItem() {

            override val itemType: ItemType = ItemType.PORTFOLIO_SUCCESS

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is PortfolioValuesItem && this.formattedPortfolioValue == other.formattedPortfolioValue
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is PortfolioValuesItem && this == other
            }
        }

        data class PortfolioValuesErrorItem(
            @ColorRes val titleColorResId: Int
        ) : BasePortfolioValueItem() {

            override val itemType: ItemType = ItemType.PORTFOLIO_ERROR

            override val errorStringResId: Int
                get() = R.string.sorry_we_cant_show_portfolio

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is PortfolioValuesErrorItem && titleColorResId == other.titleColorResId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is PortfolioValuesErrorItem && this == other
            }
        }
    }

    data class HeaderItem(@StringRes val titleResId: Int, val isWatchAccount: Boolean) : BaseAccountListItem() {

        override val itemType: ItemType = ItemType.HEADER

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && titleResId == other.titleResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && titleResId == other.titleResId
        }
    }

    sealed class BaseAccountItem : BaseAccountListItem() {

        data class AccountItem(
            val displayName: String,
            val publicKey: String,
            val formattedHoldings: String,
            val assetCount: Int,
            val accountIcon: AccountIcon
        ) : BaseAccountItem() {

            override val itemType: ItemType = ItemType.ACCOUNT_SUCCESS

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountItem && other.publicKey == publicKey
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountItem && this == other
            }
        }

        data class AccountErrorItem(
            val displayName: String,
            val publicKey: String,
            val accountIcon: AccountIcon,
            val isErrorIconVisible: Boolean
        ) : BaseAccountItem() {

            override val itemType: ItemType = ItemType.ACCOUNT_ERROR

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountErrorItem && other.publicKey == publicKey
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountErrorItem && this == other
            }
        }
    }
}
