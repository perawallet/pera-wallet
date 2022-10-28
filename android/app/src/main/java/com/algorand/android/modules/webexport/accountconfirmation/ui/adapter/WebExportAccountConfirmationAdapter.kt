/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.webexport.accountconfirmation.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.modules.webexport.accountconfirmation.ui.model.BaseAccountConfirmationListItem
import com.algorand.android.modules.webexport.accountconfirmation.ui.viewholder.AccountConfirmationItemViewHolder
import com.algorand.android.modules.webexport.accountconfirmation.ui.viewholder.WebExportAccountConfirmationTextItemViewHolder

class WebExportAccountConfirmationAdapter :
    ListAdapter<BaseAccountConfirmationListItem,
        RecyclerView.ViewHolder>(BaseDiffUtil<BaseAccountConfirmationListItem>()) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is BaseAccountConfirmationListItem.TextItem -> R.layout.item_text_simple
            is BaseAccountConfirmationListItem.AccountItem -> R.layout.item_account
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_text_simple -> createTextItemViewHolder(parent)
            R.layout.item_account -> createAccountConfirmationItemViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createAccountConfirmationItemViewHolder(parent: ViewGroup): AccountConfirmationItemViewHolder {
        return AccountConfirmationItemViewHolder.create(parent = parent)
    }

    private fun createTextItemViewHolder(parent: ViewGroup): WebExportAccountConfirmationTextItemViewHolder {
        return WebExportAccountConfirmationTextItemViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is WebExportAccountConfirmationTextItemViewHolder -> {
                holder.bind(getItem(position) as BaseAccountConfirmationListItem.TextItem)
            }
            is AccountConfirmationItemViewHolder -> {
                holder.bind(getItem(position) as BaseAccountConfirmationListItem.AccountItem)
            }
        }
    }

    companion object {
        private val logTag = WebExportAccountConfirmationAdapter::class.java
    }
}
