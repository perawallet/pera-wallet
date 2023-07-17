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

package com.algorand.android.modules.basesingleaccountselection.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basesingleaccountselection.ui.adapter.viewholder.SingleAccountSelectionAccountItemViewHolder
import com.algorand.android.modules.basesingleaccountselection.ui.adapter.viewholder.SingleAccountSelectionDescriptionItemViewHolder
import com.algorand.android.modules.basesingleaccountselection.ui.adapter.viewholder.SingleAccountSelectionTitleItemViewHolder
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem.ItemType.ACCOUNT_ITEM
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem.ItemType.DESCRIPTION_ITEM
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem.ItemType.TITLE_ITEM

class BaseSingleAccountSelectionAdapter constructor(
    private val listener: Listener
) : ListAdapter<SingleAccountSelectionListItem, BaseViewHolder<SingleAccountSelectionListItem>>(BaseDiffUtil()) {

    private val accountItemListener = object : SingleAccountSelectionAccountItemViewHolder.Listener {
        override fun onAccountItemClick(accountAddress: String) {
            listener.onAccountItemClick(accountAddress)
        }

        override fun onAccountItemLongClick(accountAddress: String) {
            listener.onAccountItemLongClick(accountAddress)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<SingleAccountSelectionListItem> {
        return when (viewType) {
            ACCOUNT_ITEM.ordinal -> createAccountItemViewHolder(parent)
            TITLE_ITEM.ordinal -> createTitleItemViewHolder(parent)
            DESCRIPTION_ITEM.ordinal -> createDescriptionItemViewHolder(parent)
            else -> throw Exception("$logTag: List Item is Unknown. $viewType")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<SingleAccountSelectionListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createAccountItemViewHolder(parent: ViewGroup): SingleAccountSelectionAccountItemViewHolder {
        return SingleAccountSelectionAccountItemViewHolder.create(parent, accountItemListener)
    }

    private fun createTitleItemViewHolder(parent: ViewGroup): SingleAccountSelectionTitleItemViewHolder {
        return SingleAccountSelectionTitleItemViewHolder.create(parent)
    }

    private fun createDescriptionItemViewHolder(parent: ViewGroup): SingleAccountSelectionDescriptionItemViewHolder {
        return SingleAccountSelectionDescriptionItemViewHolder.create(parent)
    }

    interface Listener {
        fun onAccountItemClick(accountAddress: String)
        fun onAccountItemLongClick(accountAddress: String)
    }

    companion object {
        private val logTag = BaseSingleAccountSelectionAdapter::class.java.simpleName
    }
}
