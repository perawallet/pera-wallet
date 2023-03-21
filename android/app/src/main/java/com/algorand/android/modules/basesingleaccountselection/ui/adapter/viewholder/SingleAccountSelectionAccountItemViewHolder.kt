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

package com.algorand.android.modules.basesingleaccountselection.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemSingleAccountSelectionAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem
import com.algorand.android.utils.AccountIconDrawable

class SingleAccountSelectionAccountItemViewHolder(
    private val binding: ItemSingleAccountSelectionAccountBinding,
    private val listener: Listener
) : BaseViewHolder<SingleAccountSelectionListItem>(binding.root) {

    override fun bind(item: SingleAccountSelectionListItem) {
        if (item !is SingleAccountSelectionListItem.AccountItem) return
        with(binding.accountItemView) {
            val accountIconSize = resources.getDimension(R.dimen.account_icon_size_large).toInt()
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                accountIconResource = item.accountIconResource,
                size = accountIconSize
            )
            setStartIconDrawable(accountIconDrawable)
            with(item.accountDisplayName) {
                setTitleText(getAccountPrimaryDisplayName())
                setDescriptionText(getAccountSecondaryDisplayName(resources))
                setOnLongClickListener { listener.onAccountItemLongClick(getRawAccountAddress()); true }
                setOnClickListener { listener.onAccountItemClick(getRawAccountAddress()) }
            }
            setPrimaryValueText(item.accountFormattedPrimaryValue)
            setSecondaryValueText(item.accountFormattedSecondaryValue)
        }
    }

    interface Listener {
        fun onAccountItemClick(accountAddress: String)
        fun onAccountItemLongClick(accountAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): SingleAccountSelectionAccountItemViewHolder {
            val binding = ItemSingleAccountSelectionAccountBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return SingleAccountSelectionAccountItemViewHolder(binding, listener)
        }
    }
}
