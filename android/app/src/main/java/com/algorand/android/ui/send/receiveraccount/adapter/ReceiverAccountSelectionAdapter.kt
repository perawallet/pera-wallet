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

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseReceiverAccount
import com.algorand.android.models.User

class ReceiverAccountSelectionAdapter(
    private val onAccountClick: (AccountCacheData) -> Unit,
    private val onContactClick: (User) -> Unit,
    private val onPasteClick: (String) -> Unit
) : ListAdapter<BaseReceiverAccount, RecyclerView.ViewHolder>(BaseDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is BaseReceiverAccount.HeaderItem -> {
                R.layout.item_receiver_account_header
            }
            is BaseReceiverAccount.AccountItem, is BaseReceiverAccount.ContactItem -> {
                R.layout.item_receiver_account
            }
            is BaseReceiverAccount.PasteItem -> {
                R.layout.item_receiver_account_paste
            }
            else -> throw Exception("ReceiverAccountSelectionAdapter unknown item type.")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_receiver_account_header -> HeaderItemViewHolder.create(parent)
            R.layout.item_receiver_account -> {
                ReceiverAccountViewHolder.create(parent).apply {
                    itemView.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            (getItem(bindingAdapterPosition))?.let {
                                when (it) {
                                    is BaseReceiverAccount.ContactItem -> onContactClick(it.user)
                                    is BaseReceiverAccount.AccountItem -> onAccountClick(it.accountCacheData)
                                }
                            }
                        }
                    }
                }
            }
            R.layout.item_receiver_account_paste -> {
                PasteItemViewHolder.create(parent).apply {
                    itemView.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            (getItem(bindingAdapterPosition) as? BaseReceiverAccount.PasteItem)?.let {
                                onPasteClick(it.address)
                            }
                        }
                    }
                }
            }
            else -> throw Exception("ReceiverAccountSelectionAdapter unknown item type.")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is HeaderItemViewHolder -> holder.bind(getItem(position) as BaseReceiverAccount.HeaderItem)
            is ReceiverAccountViewHolder -> holder.bind(getItem(position) as BaseReceiverAccount)
            is PasteItemViewHolder -> holder.bind(getItem(position) as BaseReceiverAccount.PasteItem)
        }
    }
}
