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
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemTransactionBinding
import com.algorand.android.models.TransactionListItem
import com.algorand.android.models.TransactionSymbol
import com.algorand.android.models.TransactionType
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.toShortenedAddress

class TransactionViewHolder(private val binding: ItemTransactionBinding) : RecyclerView.ViewHolder(binding.root) {

    fun bind(listItem: TransactionListItem) {
        with(listItem) {
            binding.pendingImageView.isVisible = transactionType == TransactionType.PENDING

            if (transactionType == TransactionType.ASSET_CREATION) {
                binding.nameTextView.text = itemView.resources.getString(R.string.add_asset_fee)
                binding.adressTextView.text = ""

                binding.amountTextView.setAmount(fee ?: 0L, ALGO_DECIMALS, true, TransactionSymbol.NEGATIVE)
            } else {
                contact.let { contactOfUser ->
                    if (contactOfUser != null) {
                        binding.nameTextView.text = contactOfUser.name
                        binding.adressTextView.text = listItem.otherPublicKey.toShortenedAddress()
                    } else {
                        binding.nameTextView.text = listItem.otherPublicKey.toShortenedAddress()
                        binding.adressTextView.text = ""
                    }
                }

                binding.amountTextView.setAmount(
                    amount,
                    formattedFullAmount,
                    isAlgorand,
                    transactionSymbol
                )
            }
            binding.dateTextView.text = listItem.date
        }
    }

    companion object {
        fun create(parent: ViewGroup): TransactionViewHolder {
            val binding = ItemTransactionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return TransactionViewHolder(binding)
        }
    }
}
