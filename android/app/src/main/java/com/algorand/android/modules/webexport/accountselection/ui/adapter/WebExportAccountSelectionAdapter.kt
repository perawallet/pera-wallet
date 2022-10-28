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

package com.algorand.android.modules.webexport.accountselection.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.R
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.webexport.accountselection.ui.model.BaseAccountMultipleSelectionListItem
import com.algorand.android.modules.webexport.accountselection.ui.viewholder.AccountMultipleSelectionHeaderItemViewHolder
import com.algorand.android.modules.webexport.accountselection.ui.viewholder.AccountSimpleHeaderItemViewHolder
import com.algorand.android.modules.webexport.accountselection.ui.viewholder.SelectableAccountItemViewHolder
import com.algorand.android.modules.webexport.accountselection.ui.viewholder.SingleAccountItemViewHolder
import com.algorand.android.modules.webexport.accountselection.ui.viewholder.TextItemViewHolder

class WebExportAccountSelectionAdapter(
    private val listener: Listener
) : ListAdapter<BaseAccountMultipleSelectionListItem, BaseViewHolder<BaseAccountMultipleSelectionListItem>>(
    BaseDiffUtil<BaseAccountMultipleSelectionListItem>()
) {

    private val accountItemViewHolderListener = SelectableAccountItemViewHolder.Listener { accountAddress ->
        listener.onAccountItemClicked(accountAddress)
    }

    private val headerItemViewHolderListener =
        AccountMultipleSelectionHeaderItemViewHolder.Listener { currentCheckBoxState ->
            listener.onCheckBoxClicked(currentCheckBoxState)
        }

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is BaseAccountMultipleSelectionListItem.TextItem -> R.layout.item_text_simple
            is BaseAccountMultipleSelectionListItem.HeaderItem ->
                if (isSingleAccountItem()) {
                    R.layout.item_simple_header
                } else {
                    R.layout.item_multiple_select_header
                }
            is BaseAccountMultipleSelectionListItem.AccountItem ->
                if (isSingleAccountItem()) {
                    R.layout.item_single_account_asset
                } else {
                    R.layout.item_selectable_account_asset
                }
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): BaseViewHolder<BaseAccountMultipleSelectionListItem> {
        return when (viewType) {
            R.layout.item_text_simple -> createTextItemViewHolder(parent)
            R.layout.item_multiple_select_header -> createHeaderItemViewHolder(parent)
            R.layout.item_simple_header -> createSimpleHeaderItemViewHolder(parent)
            R.layout.item_selectable_account_asset -> createSelectableAccountItemViewHolder(parent)
            R.layout.item_single_account_asset -> createSingleAccountItemViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createHeaderItemViewHolder(parent: ViewGroup): AccountMultipleSelectionHeaderItemViewHolder {
        return AccountMultipleSelectionHeaderItemViewHolder.create(
            parent = parent,
            listener = headerItemViewHolderListener
        )
    }

    private fun createSimpleHeaderItemViewHolder(parent: ViewGroup): AccountSimpleHeaderItemViewHolder {
        return AccountSimpleHeaderItemViewHolder.create(parent = parent)
    }

    private fun createSelectableAccountItemViewHolder(parent: ViewGroup): SelectableAccountItemViewHolder {
        return SelectableAccountItemViewHolder.create(parent = parent, listener = accountItemViewHolderListener)
    }

    private fun createSingleAccountItemViewHolder(parent: ViewGroup): SingleAccountItemViewHolder {
        return SingleAccountItemViewHolder.create(parent = parent)
    }

    private fun createTextItemViewHolder(parent: ViewGroup): TextItemViewHolder {
        return TextItemViewHolder.create(parent)
    }

    private fun isSingleAccountItem(): Boolean {
        return currentList.filter {
            it.itemType == BaseAccountMultipleSelectionListItem.ItemType.ACCOUNT
        }.size == 1
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAccountMultipleSelectionListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface Listener {
        fun onCheckBoxClicked(currentCheckBoxState: TriStatesCheckBox.CheckBoxState)
        fun onAccountItemClicked(accountAddress: String)
    }

    companion object {
        private val logTag = WebExportAccountSelectionAdapter::class.java
    }
}
