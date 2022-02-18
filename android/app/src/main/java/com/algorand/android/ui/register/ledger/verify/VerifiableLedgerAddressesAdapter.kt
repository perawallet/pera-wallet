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

package com.algorand.android.ui.register.ledger.verify

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R

class VerifiableLedgerAddressesAdapter : ListAdapter<VerifyLedgerAddressListItem, RecyclerView.ViewHolder>(
    VerifyLedgerAddressListItemDiffUtil()
) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is VerifyLedgerAddressListItem.VerifiableLedgerAddressItem -> R.layout.item_verifiable_ledger_address
            VerifyLedgerAddressListItem.VerifyLedgerHeaderItem -> R.layout.item_ledger_verify_instruction
            else -> throw Exception("VerifiableLedgerAddressesAdapter: List Item is Unknown.")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_verifiable_ledger_address -> VerifiableLedgerAddressViewHolder.create(parent)
            R.layout.item_ledger_verify_instruction -> VerifyLedgerInstructionViewHolder.create(parent)
            else -> throw Exception("VerifiableLedgerAddressesAdapter: List Item is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is VerifiableLedgerAddressViewHolder)
            holder.bind(getItem(position) as VerifyLedgerAddressListItem.VerifiableLedgerAddressItem)
    }
}
