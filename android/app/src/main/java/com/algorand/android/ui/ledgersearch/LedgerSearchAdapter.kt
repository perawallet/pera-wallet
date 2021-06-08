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

package com.algorand.android.ui.ledgersearch

import android.bluetooth.BluetoothDevice
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView

class LedgerSearchAdapter(
    private val onConnectClick: (BluetoothDevice) -> Unit
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private val ledgerBaseItemList = mutableListOf<LedgerBaseItem>(LedgerBaseItem.LedgerLoadingItem)

    fun setItems(newDeviceList: Set<BluetoothDevice>) {
        with(ledgerBaseItemList) {
            clear()
            addAll(newDeviceList.map { newDevice ->
                LedgerBaseItem.LedgerItem(newDevice)
            })
            add(LedgerBaseItem.LedgerLoadingItem)
        }
        notifyDataSetChanged()
    }

    override fun getItemViewType(position: Int): Int {
        return when (ledgerBaseItemList[position]) {
            is LedgerBaseItem.LedgerLoadingItem -> {
                LedgerBaseItem.ItemType.LOADING_ITEM.ordinal
            }
            is LedgerBaseItem.LedgerItem -> {
                LedgerBaseItem.ItemType.LEDGER_ITEM.ordinal
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            LedgerBaseItem.ItemType.LEDGER_ITEM.ordinal -> {
                LedgerSearchItemViewHolder.create(
                    parent
                ).apply {
                    binding.connectButton.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            val ledgerItem = (ledgerBaseItemList[bindingAdapterPosition] as? LedgerBaseItem.LedgerItem)
                            ledgerItem?.device?.let { device ->
                                onConnectClick.invoke(device)
                            }
                        }
                    }
                }
            }
            LedgerBaseItem.ItemType.LOADING_ITEM.ordinal -> {
                LedgerLoadingItemViewHolder.create(
                    parent
                )
            }
            else -> {
                throw Exception("Wrong Item View Type")
            }
        }
    }

    override fun getItemCount() = ledgerBaseItemList.size

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is LedgerSearchItemViewHolder) {
            holder.bind((ledgerBaseItemList[position] as LedgerBaseItem.LedgerItem))
        }
    }
}
