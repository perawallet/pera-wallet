/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.ui.accountselection.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountErrorSimpleBinding
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AccountIconResource.Companion.DEFAULT_ACCOUNT_ICON_RESOURCE
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.utils.AccountIconDrawable

class AccountSelectionAccountErrorItemViewHolder(
    private val binding: ItemAccountErrorSimpleBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: BaseAccountSelectionListItem.BaseAccountItem.AccountErrorItem) {
        with(binding) {
            with(item.accountListItem.itemConfiguration) {
                setAccountStartIconDrawable(accountIconResource)
                setAccountTitleText(accountDisplayName?.getAccountPrimaryDisplayName())
                setAccountDescriptionText(accountDisplayName?.getAccountSecondaryDisplayName(root.resources))
                setAccountEndIconDrawable()
            }
        }
    }

    private fun setAccountStartIconDrawable(accountIconResource: AccountIconResource?) {
        with(binding.accountItemView) {
            val accountIconSize = resources.getDimension(R.dimen.account_icon_size_large).toInt()
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                accountIconResource = accountIconResource ?: DEFAULT_ACCOUNT_ICON_RESOURCE,
                size = accountIconSize
            )
            setStartIconDrawable(accountIconDrawable)
        }
    }

    private fun setAccountTitleText(accountTitleText: String?) {
        binding.accountItemView.setTitleText(accountTitleText)
    }

    private fun setAccountDescriptionText(accountDescriptionText: String?) {
        binding.accountItemView.setDescriptionText(accountDescriptionText)
    }

    private fun setAccountEndIconDrawable() {
        with(binding) {
            val tintColor = ContextCompat.getColor(root.context, R.color.negative)
            val endIconDrawable = AppCompatResources.getDrawable(root.context, R.drawable.ic_info)?.apply {
                setTint(tintColor)
            }
            accountItemView.setEndIconDrawable(endIconDrawable)
        }
    }

    companion object {
        fun create(parent: ViewGroup): AccountSelectionAccountErrorItemViewHolder {
            val binding = ItemAccountErrorSimpleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountSelectionAccountErrorItemViewHolder(binding)
        }
    }
}
