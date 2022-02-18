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

package com.algorand.android.ui.ledgersearch.ledgerinformation

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.models.LedgerInformationListItemDiffUtil

class LedgerInformationAdapter : ListAdapter<LedgerInformationListItem, RecyclerView.ViewHolder>(
    LedgerInformationListItemDiffUtil()
) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is LedgerInformationListItem.TitleItem -> R.layout.item_ledger_information_title
            is LedgerInformationListItem.AssetInformationItem -> R.layout.item_ledger_information_asset
            is LedgerInformationListItem.AccountItem -> R.layout.item_ledger_information_account
            is LedgerInformationListItem.CanSignedByItem -> R.layout.item_ledger_information_can_sign
            else -> throw Exception("$logTag: List Item is Unknown.")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_ledger_information_title -> TitleItemViewHolder.create(parent)
            R.layout.item_ledger_information_asset -> AssetInformationItemViewHolder.create(parent)
            R.layout.item_ledger_information_account -> AccountItemViewHolder.create(parent)
            R.layout.item_ledger_information_can_sign -> CanSignedByItemViewHolder.create(parent)
            else -> throw Exception("$logTag: List Item is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is TitleItemViewHolder -> {
                holder.bind(getItem(position) as LedgerInformationListItem.TitleItem)
            }
            is AccountItemViewHolder -> {
                holder.bind(getItem(position) as LedgerInformationListItem.AccountItem)
            }
            is AssetInformationItemViewHolder -> {
                holder.bind(getItem(position) as LedgerInformationListItem.AssetInformationItem)
            }
            is CanSignedByItemViewHolder -> {
                holder.bind(getItem(position) as LedgerInformationListItem.CanSignedByItem)
            }
        }
    }

    companion object {
        private val logTag = LedgerInformationAdapter::class.java.simpleName
    }
}
