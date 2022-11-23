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

package com.algorand.android.modules.swap.transactionsummary.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem.ItemType

class SwapTransactionSummaryAdapter(
    private val listener: SwapSummaryAdapterListener
) : ListAdapter<BaseSwapTransactionSummaryItem, BaseViewHolder<BaseSwapTransactionSummaryItem>>(BaseDiffUtil()) {

    private val swapAccountItemListener = SwapAccountItemViewHolder.SwapAccountItemListener { accountAddress ->
        listener.onAccountAddressLongClick(accountAddress)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position)?.itemType?.ordinal ?: RecyclerView.NO_POSITION
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseSwapTransactionSummaryItem> {
        return when (viewType) {
            ItemType.SWAP_AMOUNTS_ITEM.ordinal -> createSwapAmountItemViewHolder(parent)
            ItemType.SWAP_ACCOUNT_ITEM.ordinal -> createSwapAccountItemViewHolder(parent)
            ItemType.SWAP_FEES_ITEM.ordinal -> createSwapFeesItemViewHolder(parent)
            ItemType.SWAP_PRICE_IMPACT_ITEM.ordinal -> createSwapPriceImpactItemViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createSwapAmountItemViewHolder(parent: ViewGroup): SwapAmountsItemViewHolder {
        return SwapAmountsItemViewHolder.create(parent)
    }

    private fun createSwapAccountItemViewHolder(parent: ViewGroup): SwapAccountItemViewHolder {
        return SwapAccountItemViewHolder.create(parent, swapAccountItemListener)
    }

    private fun createSwapFeesItemViewHolder(parent: ViewGroup): SwapFeesItemViewHolder {
        return SwapFeesItemViewHolder.create(parent)
    }

    private fun createSwapPriceImpactItemViewHolder(parent: ViewGroup): SwapPriceImpactItemViewHolder {
        return SwapPriceImpactItemViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseSwapTransactionSummaryItem>, position: Int) {
        holder.bind(getItem(position))
    }

    fun interface SwapSummaryAdapterListener {
        fun onAccountAddressLongClick(accountAddress: String)
    }

    companion object {
        private val logTag = this::class.java.simpleName
    }
}
