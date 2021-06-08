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

package com.algorand.android.ui.common.accountselector

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemAccountOptionBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import java.math.BigInteger

class AccountsSelectorAdapter(
    private val onAccountSelect: (AccountCacheData, AssetInformation) -> Unit,
    private val showBalance: Boolean
) : RecyclerView.Adapter<AccountsSelectorAdapter.AccountViewHolder>() {

    private var accountCountsList = mutableListOf<Pair<AccountCacheData, AssetInformation>>()

    fun setData(list: List<Pair<AccountCacheData, AssetInformation>>) {
        accountCountsList.clear()
        accountCountsList.addAll(list)
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return accountCountsList.size
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AccountViewHolder {
        return AccountViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    val (account, asset) = accountCountsList[bindingAdapterPosition]
                    onAccountSelect(account, asset)
                }
            }
        }
    }

    override fun onBindViewHolder(holder: AccountViewHolder, position: Int) {
        holder.bind(accountCountsList[position], showBalance)
    }

    class AccountViewHolder(
        private val binding: ItemAccountOptionBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(accountAssetPair: Pair<AccountCacheData, AssetInformation>, showBalance: Boolean) {
            val (accountCacheData, asset) = accountAssetPair
            binding.nameTextView.text = accountCacheData.account.name
            binding.typeImageView.setImageResource(accountCacheData.getImageResource())
            if (showBalance) {
                with(asset) {
                    binding.balanceTextView.setAmount(amount ?: BigInteger.ZERO, decimals, isAlgorand())
                }
            }
        }

        companion object {
            fun create(parent: ViewGroup): AccountViewHolder {
                val binding = ItemAccountOptionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                return AccountViewHolder(binding)
            }
        }
    }
}
