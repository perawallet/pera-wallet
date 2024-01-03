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

package com.algorand.android.modules.sorting.accountsorting.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.sorting.accountsorting.domain.model.BaseAccountSortingListItem
import com.algorand.android.modules.sorting.accountsorting.ui.viewholder.AccountSortItemViewHolder
import com.algorand.android.modules.sorting.accountsorting.ui.viewholder.ListHeaderViewHolder

class AccountSortAdapter(
    private val accountSortAdapterListener: AccountSortAdapterListener
) : ListAdapter<BaseAccountSortingListItem, BaseViewHolder<BaseAccountSortingListItem>>(BaseDiffUtil()) {

    private val accountSortItemListener = AccountSortItemViewHolder.DragButtonPressedListener {
        accountSortAdapterListener.onSortableItemPressed(it)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position)?.itemType?.ordinal ?: RecyclerView.NO_POSITION
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseAccountSortingListItem> {
        return when (viewType) {
            BaseAccountSortingListItem.ItemType.HEADER.ordinal -> createSortableHeaderViewHolder(parent)
            BaseAccountSortingListItem.ItemType.ACCOUNT_SORT.ordinal -> createAccountSortViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createSortableHeaderViewHolder(parent: ViewGroup): ListHeaderViewHolder {
        return ListHeaderViewHolder.create(parent)
    }

    private fun createAccountSortViewHolder(parent: ViewGroup): AccountSortItemViewHolder {
        return AccountSortItemViewHolder.create(parent, accountSortItemListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAccountSortingListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    fun interface AccountSortAdapterListener {
        fun onSortableItemPressed(viewHolder: BaseViewHolder<BaseAccountSortingListItem>)
    }

    companion object {
        private val logTag = AccountSortAdapter::class.simpleName
    }
}
