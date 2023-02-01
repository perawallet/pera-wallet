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

package com.algorand.android.modules.accounts.ui.viewholder

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountErrorBinding
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AccountIconResource.Companion.DEFAULT_ACCOUNT_ICON_RESOURCE
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem
import com.algorand.android.utils.AccountIconDrawable

class AccountErrorItemViewHolder(
    val binding: ItemAccountErrorBinding,
    val listener: AccountClickListener
) : BaseViewHolder<BaseAccountListItem>(binding.root) {

    override fun bind(item: BaseAccountListItem) {
        if (item !is BaseAccountListItem.BaseAccountItem.AccountErrorItem) return
        with(binding) {
            with(item.accountListItem.itemConfiguration) {
                setAccountStartIconDrawable(accountIconResource)
                setAccountTitleText(accountDisplayName?.getAccountPrimaryDisplayName())
                setAccountDescriptionText(accountDisplayName?.getAccountSecondaryDisplayName(root.resources))
                setAccountEndIconDrawable()
                root.setOnClickListener { listener.onAccountClick(accountAddress) }
                root.setOnLongClickListener(getOnLongClickListener(item.canCopyable, accountAddress))
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

    private fun getOnLongClickListener(canCopyable: Boolean, accountAddress: String): View.OnLongClickListener? {
        return if (canCopyable) {
            View.OnLongClickListener { listener.onAccountLongPress(accountAddress); true }
        } else {
            null
        }
    }

    companion object {
        fun create(parent: ViewGroup, listener: AccountClickListener): AccountErrorItemViewHolder {
            val binding = ItemAccountErrorBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountErrorItemViewHolder(binding, listener)
        }
    }

    interface AccountClickListener {
        fun onAccountClick(publicKey: String)
        fun onAccountLongPress(publicKey: String)
    }
}
