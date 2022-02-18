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

import java.math.BigInteger

sealed class AccountHistoryItem : RecyclerListItem {

    data class HeaderItem(val title: String) : AccountHistoryItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && other.title == title
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && this == other
        }
    }

    data class HistoryItem(
        val title: String,
        val description: String,
        val amount: BigInteger,
        val asset: Asset?,
        val roundTimeAsTimestamp: Long?,
        val transactionSymbol: TransactionSymbol?
    ) : AccountHistoryItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HistoryItem &&
                title == other.title &&
                description == other.description &&
                amount == other.amount &&
                asset == other.asset &&
                roundTimeAsTimestamp == other.roundTimeAsTimestamp
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HistoryItem && this == other
        }
    }

    data class PendingItem(
        val title: String,
        val description: String,
        val amount: BigInteger,
        val asset: Asset?,
        val transactionSymbol: TransactionSymbol?
    ) : AccountHistoryItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is PendingItem &&
                title == other.title &&
                description == other.description &&
                amount == other.amount &&
                asset == other.asset
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is PendingItem && other == this
        }
    }
}
