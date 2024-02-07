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

package com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountSelectionBinding
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.utils.AccountIconDrawable

class LedgerAccountSelectionViewHolder(
    private val binding: ItemAccountSelectionBinding,
    private val listener: Listener
) : BaseViewHolder<AccountSelectionListItem>(binding.root) {

    override fun bind(item: AccountSelectionListItem) {
        if (item !is AccountSelectionListItem.AccountItem) return
        with(binding) {
            bindSelection(item.isSelected)
            selectionIndicatorImageView.setImageResource(item.selectorDrawableRes)
            accountItemView.apply {
                val accountIconDrawable = AccountIconDrawable.create(
                    context = context,
                    sizeResId = R.dimen.spacing_xxxxlarge,
                    accountIconDrawablePreview = item.accountIconDrawablePreview
                )
                setStartIconDrawable(accountIconDrawable)
                setTitleText(item.accountDisplayName.getAccountPrimaryDisplayName())
                setDescriptionText(item.accountDisplayName.getAccountSecondaryDisplayName(resources))
                setEndIconResource(R.drawable.ic_info)
                setEndIconClickListener { listener.onAccountInfoClick(item) }
            }
            root.setOnClickListener { listener.onAccountItemClick(item) }
        }
    }

    private fun bindSelection(isSelected: Boolean) {
        with(binding) {
            if (isSelected) {
                parentLayout.setBackgroundResource(SELECTED_ITEM_BACKGROUND)
            } else {
                parentLayout.setBackgroundResource(UNSELECTED_ITEM_BACKGROUND)
            }
            selectionIndicatorImageView.isSelected = isSelected
        }
    }

    interface Listener {
        fun onAccountItemClick(accountItem: AccountSelectionListItem.AccountItem)
        fun onAccountInfoClick(accountItem: AccountSelectionListItem.AccountItem)
    }

    companion object {
        private val SELECTED_ITEM_BACKGROUND = R.drawable.bg_selected_ledger_account
        private val UNSELECTED_ITEM_BACKGROUND = R.drawable.bg_rectangle_radius_12_stroke_1

        fun create(parent: ViewGroup, listener: Listener): LedgerAccountSelectionViewHolder {
            val binding = ItemAccountSelectionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LedgerAccountSelectionViewHolder(binding, listener)
        }
    }
}
