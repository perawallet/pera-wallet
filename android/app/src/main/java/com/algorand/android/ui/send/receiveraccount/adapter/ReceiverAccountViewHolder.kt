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

package com.algorand.android.ui.send.receiveraccount.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.net.toUri
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemReceiverAccountBinding
import com.algorand.android.models.BaseReceiverAccount

class ReceiverAccountViewHolder(
    private val binding: ItemReceiverAccountBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(baseReceiverAccount: BaseReceiverAccount) {
        when (baseReceiverAccount) {
            is BaseReceiverAccount.AccountItem -> bindAccountItem(baseReceiverAccount)
            is BaseReceiverAccount.ContactItem -> bindContactItem(baseReceiverAccount)
        }
    }

    private fun bindAccountItem(accountItem: BaseReceiverAccount.AccountItem) {
        with(binding) {
            with(accountItem.accountCacheData.account) {
                accountImageview.setAccountIcon(accountItem.accountCacheData.account.createAccountIcon())
                accountNameTextView.text = name
            }
        }
    }

    private fun bindContactItem(contactItem: BaseReceiverAccount.ContactItem) {
        with(binding) {
            with(contactItem.user) {
                accountImageview.loadAccountImage(imageUriAsString?.toUri())
                accountNameTextView.text = name
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): ReceiverAccountViewHolder {
            val binding = ItemReceiverAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ReceiverAccountViewHolder(binding)
        }
    }
}
