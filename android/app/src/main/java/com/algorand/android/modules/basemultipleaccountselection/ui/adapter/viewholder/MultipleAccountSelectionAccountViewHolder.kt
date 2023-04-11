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

package com.algorand.android.modules.basemultipleaccountselection.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemMultipleAccountSelectionAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.utils.AccountIconDrawable

class MultipleAccountSelectionAccountViewHolder(
    private val binding: ItemMultipleAccountSelectionAccountBinding,
    private val listener: Listener
) : BaseViewHolder<MultipleAccountSelectionListItem>(binding.root) {

    override fun bind(item: MultipleAccountSelectionListItem) {
        if (item !is MultipleAccountSelectionListItem.AccountItem) return
        with(binding.multipleAccountSelectionStatefulAccountView) {
            val accountIconSize = resources.getDimension(R.dimen.account_icon_size_large).toInt()
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                accountIconResource = item.accountIconResource,
                size = accountIconSize
            )
            setStartIconDrawable(accountIconDrawable)
            setButtonState(item.accountViewButtonState)
            with(item.accountDisplayName) {
                setTitleText(getAccountPrimaryDisplayName())
                setDescriptionText(getAccountSecondaryDisplayName(resources))
                setOnLongClickListener { listener.onAccountLongPressed(getRawAccountAddress()); true }
                setActionButtonClickListener { listener.onAccountCheckBoxClicked(getRawAccountAddress()) }
                setOnClickListener { listener.onAccountCheckBoxClicked(getRawAccountAddress()) }
            }
        }
    }

    interface Listener {
        fun onAccountCheckBoxClicked(accountAddress: String)
        fun onAccountLongPressed(accountAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): MultipleAccountSelectionAccountViewHolder {
            val binding = ItemMultipleAccountSelectionAccountBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return MultipleAccountSelectionAccountViewHolder(binding, listener)
        }
    }
}
