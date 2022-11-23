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

package com.algorand.android.modules.swap.transactionsummary.ui.model

import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.utils.AccountDisplayName

sealed class BaseSwapTransactionSummaryItem : RecyclerListItem {

    enum class ItemType {
        SWAP_AMOUNTS_ITEM,
        SWAP_ACCOUNT_ITEM,
        SWAP_FEES_ITEM,
        SWAP_PRICE_IMPACT_ITEM
    }

    abstract val itemType: ItemType

    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
        return other is BaseSwapTransactionSummaryItem && itemType == other.itemType
    }

    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
        return other is BaseSwapTransactionSummaryItem && this == other
    }

    data class SwapAmountsItemTransaction(
        val formattedReceivedAmount: String,
        val formattedPaidAmount: String
    ) : BaseSwapTransactionSummaryItem() {
        override val itemType = ItemType.SWAP_AMOUNTS_ITEM
    }

    data class SwapAccountItemTransaction(
        val accountDisplayName: AccountDisplayName,
        val accountIconResource: AccountIconResource
    ) : BaseSwapTransactionSummaryItem() {
        override val itemType = ItemType.SWAP_ACCOUNT_ITEM
    }

    data class SwapFeesItemTransaction(
        val formattedAlgorandFees: String,
        val formattedOptInFees: String,
        val isOptInFeesVisible: Boolean,
        val formattedExchangeFees: String,
        val isExchangeFeesVisible: Boolean,
        val formattedPeraFees: String,
        val isPeraFeeVisible: Boolean
    ) : BaseSwapTransactionSummaryItem() {
        override val itemType = ItemType.SWAP_FEES_ITEM
    }

    data class SwapPriceImpactItemTransaction(
        val priceImpact: String
    ) : BaseSwapTransactionSummaryItem() {
        override val itemType = ItemType.SWAP_PRICE_IMPACT_ITEM
    }
}
