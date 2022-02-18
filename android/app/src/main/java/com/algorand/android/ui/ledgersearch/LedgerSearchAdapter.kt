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

package com.algorand.android.ui.ledgersearch

import android.bluetooth.BluetoothDevice
import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.BaseDiffUtil

class LedgerSearchAdapter(
    private val onConnectClick: (BluetoothDevice) -> Unit
) : ListAdapter<LedgerBaseItem, RecyclerView.ViewHolder>(BaseDiffUtil<LedgerBaseItem>()) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is LedgerBaseItem.LedgerLoadingItem -> R.layout.item_ledger_search_loading
            is LedgerBaseItem.LedgerItem -> R.layout.item_scanned_ledger
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_scanned_ledger -> {
                LedgerSearchItemViewHolder.create(parent).apply {
                    itemView.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            (getItem(bindingAdapterPosition) as? LedgerBaseItem.LedgerItem)?.device?.let(
                                onConnectClick
                            )
                        }
                    }
                }
            }
            R.layout.item_ledger_search_loading -> LedgerLoadingItemViewHolder.create(parent)
            else -> throw Exception("$logTag: List Item is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is LedgerSearchItemViewHolder) {
            holder.bind((getItem(position) as LedgerBaseItem.LedgerItem))
        }
    }

    companion object {
        private val logTag = LedgerSearchAdapter::class.java.simpleName
    }
}
