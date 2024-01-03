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

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.algorand.android.databinding.ItemSwapFeesBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem

class SwapFeesItemViewHolder(
    private val binding: ItemSwapFeesBinding
) : BaseViewHolder<BaseSwapTransactionSummaryItem>(binding.root) {

    override fun bind(item: BaseSwapTransactionSummaryItem) {
        if (item !is BaseSwapTransactionSummaryItem.SwapFeesItemTransaction) return
        with(item) {
            with(binding) {
                algorandFeesTextView.text = formattedAlgorandFees
                exchangeFeesTextView.text = formattedExchangeFees
                peraFeesTextView.text = formattedPeraFees
                optinFeesTextView.text = formattedOptInFees

                optInFeesGroup.isVisible = isOptInFeesVisible
                peraFeesGroup.isVisible = isPeraFeeVisible
                exchangeFeesGroup.isVisible = isExchangeFeesVisible
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): SwapFeesItemViewHolder {
            val binding = ItemSwapFeesBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return SwapFeesItemViewHolder(binding)
        }
    }
}
