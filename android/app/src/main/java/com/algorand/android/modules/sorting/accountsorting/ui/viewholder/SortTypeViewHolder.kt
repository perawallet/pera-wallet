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

package com.algorand.android.modules.sorting.accountsorting.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemSortTypeBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.sorting.accountsorting.domain.model.AccountSortingType
import com.algorand.android.modules.sorting.accountsorting.domain.model.BaseAccountSortingListItem

class SortTypeViewHolder(
    private val binding: ItemSortTypeBinding,
    private val listener: SortingTypeListener
) : BaseViewHolder<BaseAccountSortingListItem>(binding.root) {

    override fun bind(item: BaseAccountSortingListItem) {
        if (item !is BaseAccountSortingListItem.SortTypeListItem) return
        with(binding.sortingTypeRadioButton) {
            setText(item.accountSortingType.textResId)
            isChecked = item.isChecked
            setOnClickListener { listener.onClick(item.accountSortingType) }
        }
    }

    fun interface SortingTypeListener {
        fun onClick(accountSortingType: AccountSortingType)
    }

    companion object {
        fun create(parent: ViewGroup, listener: SortingTypeListener): SortTypeViewHolder {
            val binding = ItemSortTypeBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return SortTypeViewHolder(binding, listener)
        }
    }
}
