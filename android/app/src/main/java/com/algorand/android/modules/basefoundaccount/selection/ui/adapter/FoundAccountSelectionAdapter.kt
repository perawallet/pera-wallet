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

package com.algorand.android.modules.basefoundaccount.selection.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basefoundaccount.selection.ui.adapter.viewholder.FoundAccountSelectionAccountViewHolder
import com.algorand.android.modules.basefoundaccount.selection.ui.adapter.viewholder.FoundAccountSelectionDescriptionViewHolder
import com.algorand.android.modules.basefoundaccount.selection.ui.adapter.viewholder.FoundAccountSelectionIconViewHolder
import com.algorand.android.modules.basefoundaccount.selection.ui.adapter.viewholder.FoundAccountSelectionTitleViewHolder
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem.ItemType.ACCOUNT_ITEM
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem.ItemType.DESCRIPTION_ITEM
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem.ItemType.ICON_ITEM
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem.ItemType.TITLE_ITEM

class FoundAccountSelectionAdapter(
    private val listener: Listener
) : ListAdapter<BaseFoundAccountSelectionItem, BaseViewHolder<BaseFoundAccountSelectionItem>>(BaseDiffUtil()) {

    private val accountViewHolderListener = object : FoundAccountSelectionAccountViewHolder.Listener {
        override fun onAccountItemClick(accountAddress: String) {
            listener.onAccountItemClick(accountAddress)
        }

        override fun onAccountItemInformationClick(accountAddress: String) {
            listener.onAccountItemInformationClick(accountAddress)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseFoundAccountSelectionItem> {
        return when (viewType) {
            ICON_ITEM.ordinal -> createIconViewHolder(parent)
            TITLE_ITEM.ordinal -> createTitleViewHolder(parent)
            DESCRIPTION_ITEM.ordinal -> createDescriptionViewHolder(parent)
            ACCOUNT_ITEM.ordinal -> createAccountViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag: Item View Type is Unknown.")
        }
    }

    private fun createIconViewHolder(parent: ViewGroup): FoundAccountSelectionIconViewHolder {
        return FoundAccountSelectionIconViewHolder.create(parent)
    }

    private fun createTitleViewHolder(parent: ViewGroup): FoundAccountSelectionTitleViewHolder {
        return FoundAccountSelectionTitleViewHolder.create(parent)
    }

    private fun createDescriptionViewHolder(parent: ViewGroup): FoundAccountSelectionDescriptionViewHolder {
        return FoundAccountSelectionDescriptionViewHolder.create(parent)
    }

    private fun createAccountViewHolder(parent: ViewGroup): FoundAccountSelectionAccountViewHolder {
        return FoundAccountSelectionAccountViewHolder.create(parent, accountViewHolderListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseFoundAccountSelectionItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface Listener {
        fun onAccountItemClick(accountAddress: String)
        fun onAccountItemInformationClick(accountAddress: String)
    }

    companion object {
        private val logTag = FoundAccountSelectionAdapter::class.simpleName
    }
}
