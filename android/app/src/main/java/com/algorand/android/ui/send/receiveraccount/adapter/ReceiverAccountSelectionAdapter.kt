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
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.BaseDiffUtil

class ReceiverAccountSelectionAdapter(
    private val onAccountClick: (String) -> Unit,
    private val onContactClick: (String) -> Unit,
    private val onPasteClick: (String) -> Unit
) : ListAdapter<BaseAccountSelectionListItem, RecyclerView.ViewHolder>(BaseDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is BaseAccountSelectionListItem.HeaderItem -> R.layout.item_receiver_account_header
            is BaseAccountSelectionListItem.BaseAccountItem -> R.layout.item_receiver_account
            is BaseAccountSelectionListItem.PasteItem -> R.layout.item_paste_address
            else -> throw Exception("$logTag unknown item type.")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_receiver_account_header -> createHeaderItemViewHolder(parent)
            R.layout.item_receiver_account -> createAccountItemViewHolder(parent)
            R.layout.item_paste_address -> createPasteItemViewHolder(parent)
            else -> throw Exception("ReceiverAccountSelectionAdapter unknown item type.")
        }
    }

    private fun createHeaderItemViewHolder(parent: ViewGroup): HeaderItemViewHolder {
        return HeaderItemViewHolder.create(parent)
    }

    private fun createAccountItemViewHolder(parent: ViewGroup): ReceiverAccountViewHolder {
        return ReceiverAccountViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    (getItem(bindingAdapterPosition))?.let {
                        when (it) {
                            is BaseAccountSelectionListItem.BaseAccountItem.ContactItem -> {
                                onContactClick(it.publicKey)
                            }
                            is BaseAccountSelectionListItem.BaseAccountItem.AccountItem -> {
                                onAccountClick(it.publicKey)
                            }
                        }
                    }
                }
            }
        }
    }

    private fun createPasteItemViewHolder(parent: ViewGroup): PasteItemViewHolder {
        return PasteItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    (getItem(bindingAdapterPosition) as? BaseAccountSelectionListItem.PasteItem)?.let {
                        onPasteClick(it.publicKey)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is HeaderItemViewHolder -> holder.bind(getItem(position) as BaseAccountSelectionListItem.HeaderItem)
            is ReceiverAccountViewHolder -> holder.bind(
                getItem(position) as BaseAccountSelectionListItem.BaseAccountItem
            )
            is PasteItemViewHolder -> holder.bind(getItem(position) as BaseAccountSelectionListItem.PasteItem)
            else -> throw Exception("$logTag unknown item type.")
        }
    }

    companion object {
        private val logTag = ReceiverAccountSelectionAdapter::class.simpleName
    }
}
