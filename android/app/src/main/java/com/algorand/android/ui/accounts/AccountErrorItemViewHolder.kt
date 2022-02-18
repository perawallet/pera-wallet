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
import androidx.core.view.isVisible
import com.algorand.android.databinding.ItemAccountErrorBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.ui.common.listhelper.BaseAccountListItem

class AccountErrorItemViewHolder(
    val binding: ItemAccountErrorBinding,
    val listener: AccountClickListener
) : BaseViewHolder<BaseAccountListItem>(binding.root) {

    override fun bind(item: BaseAccountListItem) {
        if (item !is BaseAccountListItem.BaseAccountItem.AccountErrorItem) return
        with(binding) {
            root.setOnClickListener { listener.onAccountClick(item.publicKey) }
            accountDisplayNameTextView.text = item.displayName
            errorIconImageView.isVisible = item.isErrorIconVisible
            accountIconImageView.setAccountIcon(item.accountIcon)
        }
    }

    companion object {
        fun create(parent: ViewGroup, listener: AccountClickListener): AccountErrorItemViewHolder {
            val binding = ItemAccountErrorBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountErrorItemViewHolder(binding, listener)
        }
    }

    fun interface AccountClickListener {
        fun onAccountClick(publicKey: String)
    }
}
