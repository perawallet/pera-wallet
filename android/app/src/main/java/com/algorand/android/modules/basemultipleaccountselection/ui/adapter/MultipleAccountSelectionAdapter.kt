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

package com.algorand.android.modules.basemultipleaccountselection.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basemultipleaccountselection.ui.adapter.viewholder.MultipleAccountSelectionAccountHeaderViewHolder
import com.algorand.android.modules.basemultipleaccountselection.ui.adapter.viewholder.MultipleAccountSelectionAccountViewHolder
import com.algorand.android.modules.basemultipleaccountselection.ui.adapter.viewholder.MultipleAccountSelectionDescriptionViewHolder
import com.algorand.android.modules.basemultipleaccountselection.ui.adapter.viewholder.MultipleAccountSelectionTitleViewHolder
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem.ItemType

class MultipleAccountSelectionAdapter(
    private val listener: Listener
) : ListAdapter<MultipleAccountSelectionListItem, BaseViewHolder<MultipleAccountSelectionListItem>>(BaseDiffUtil()) {

    private val accountHeaderItemListener = MultipleAccountSelectionAccountHeaderViewHolder.Listener {
        listener.onHeaderCheckBoxClicked()
    }

    private val accountItemListener = object : MultipleAccountSelectionAccountViewHolder.Listener {
        override fun onAccountCheckBoxClicked(accountAddress: String) {
            listener.onAccountCheckboxClicked(accountAddress)
        }

        override fun onAccountLongPressed(accountAddress: String) {
            listener.onAccountLongPressed(accountAddress)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): BaseViewHolder<MultipleAccountSelectionListItem> {
        return when (viewType) {
            ItemType.TITLE_ITEM.ordinal -> createTitleItemViewHolder(parent)
            ItemType.DESCRIPTION_ITEM.ordinal -> createDescriptionItemViewHolder(parent)
            ItemType.ACCOUNT_HEADER_ITEM.ordinal -> createAccountHeaderItemViewHolder(parent)
            ItemType.ACCOUNT_ITEM.ordinal -> createAccountItemViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag : Unknown view type $viewType")
        }
    }

    private fun createTitleItemViewHolder(parent: ViewGroup): BaseViewHolder<MultipleAccountSelectionListItem> {
        return MultipleAccountSelectionTitleViewHolder.create(parent)
    }

    private fun createDescriptionItemViewHolder(parent: ViewGroup): BaseViewHolder<MultipleAccountSelectionListItem> {
        return MultipleAccountSelectionDescriptionViewHolder.create(parent)
    }

    private fun createAccountHeaderItemViewHolder(parent: ViewGroup): BaseViewHolder<MultipleAccountSelectionListItem> {
        return MultipleAccountSelectionAccountHeaderViewHolder.create(parent, accountHeaderItemListener)
    }

    private fun createAccountItemViewHolder(parent: ViewGroup): BaseViewHolder<MultipleAccountSelectionListItem> {
        return MultipleAccountSelectionAccountViewHolder.create(parent, accountItemListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<MultipleAccountSelectionListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface Listener {
        fun onHeaderCheckBoxClicked()
        fun onAccountCheckboxClicked(accountAddress: String)
        fun onAccountLongPressed(accountAddress: String)
    }

    companion object {
        private val logTag = MultipleAccountSelectionAdapter::class.simpleName
    }
}
