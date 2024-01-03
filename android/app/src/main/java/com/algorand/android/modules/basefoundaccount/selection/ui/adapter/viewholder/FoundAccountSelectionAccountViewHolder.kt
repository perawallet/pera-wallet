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

package com.algorand.android.modules.basefoundaccount.selection.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemFoundAccountSelectionAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem
import com.algorand.android.utils.AccountIconDrawable

class FoundAccountSelectionAccountViewHolder(
    private val binding: ItemFoundAccountSelectionAccountBinding,
    private val listener: Listener
) : BaseViewHolder<BaseFoundAccountSelectionItem>(binding.root) {

    override fun bind(item: BaseFoundAccountSelectionItem) {
        if (item !is BaseFoundAccountSelectionItem.AccountItem) return
        val accountAddress = item.accountDisplayName.getRawAccountAddress()
        binding.multipleAccountSelectionStatefulAccountView.apply {
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                sizeResId = R.dimen.spacing_xxxxlarge,
                accountIconDrawablePreview = item.accountIconDrawablePreview
            )
            setStartIconDrawable(accountIconDrawable)
            setTitleText(item.accountDisplayName.getAccountPrimaryDisplayName())
            setDescriptionText(item.accountDisplayName.getAccountSecondaryDisplayName(resources))
            setEndIconResource(R.drawable.ic_info)
            setEndIconClickListener { listener.onAccountItemInformationClick(accountAddress) }
        }
        binding.root.setOnClickListener { listener.onAccountItemClick(accountAddress) }
        binding.selectionIndicatorButton.apply {
            isSelected = item.isSelected
            setIconResource(item.selectorDrawableRes)
            setOnClickListener { listener.onAccountItemClick(accountAddress) }
        }
        binding.parentLayout.apply {
            isSelected = item.isSelected
            setBackgroundResource(R.drawable.bg_selector_found_account)
        }
    }

    interface Listener {
        fun onAccountItemClick(accountAddress: String)
        fun onAccountItemInformationClick(accountAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): FoundAccountSelectionAccountViewHolder {
            val binding = ItemFoundAccountSelectionAccountBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return FoundAccountSelectionAccountViewHolder(binding, listener)
        }
    }
}
