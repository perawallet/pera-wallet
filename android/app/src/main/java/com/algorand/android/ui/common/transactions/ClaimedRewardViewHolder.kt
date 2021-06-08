/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.common.transactions

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemClaimedRewardBinding
import com.algorand.android.models.ClaimedRewardListItem
import com.algorand.android.models.TransactionSymbol
import com.algorand.android.utils.ALGO_DECIMALS

class ClaimedRewardViewHolder(
    private val binding: ItemClaimedRewardBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(claimedRewardListItem: ClaimedRewardListItem) {
        binding.amountTextView.setAmount(
            claimedRewardListItem.amountInMicroAlgos.toBigInteger(),
            ALGO_DECIMALS,
            true,
            TransactionSymbol.POSITIVE
        )
        binding.dateTextView.text = claimedRewardListItem.date
    }

    companion object {
        fun create(parent: ViewGroup): ClaimedRewardViewHolder {
            val binding = ItemClaimedRewardBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ClaimedRewardViewHolder(binding)
        }
    }
}
