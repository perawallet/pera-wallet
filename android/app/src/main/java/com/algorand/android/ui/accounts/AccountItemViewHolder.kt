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

package com.algorand.android.ui.accounts

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.ui.common.listhelper.BaseAccountListItem

class AccountItemViewHolder(
    val binding: ItemAccountBinding,
    val listener: AccountClickListener
) : BaseViewHolder<BaseAccountListItem>(binding.root) {

    override fun bind(item: BaseAccountListItem) {
        if (item !is BaseAccountListItem.BaseAccountItem.AccountItem) return
        with(binding) {
            root.setOnClickListener { listener.onAccountClick(item.publicKey) }
            accountDisplayNameTextView.text = item.displayName
            accountHoldingsTextView.text = item.formattedHoldings
            assetCountTextView.text = root.resources.getQuantityString(
                R.plurals.account_asset_count,
                item.assetCount,
                item.assetCount,
                item.assetCount
            )
            accountIconImageView.setAccountIcon(item.accountIcon)
        }
    }

    companion object {
        fun create(parent: ViewGroup, listener: AccountClickListener): AccountItemViewHolder {
            val binding = ItemAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountItemViewHolder(binding, listener)
        }
    }

    fun interface AccountClickListener {
        fun onAccountClick(publicKey: String)
    }
}
