/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.webexport.accountconfirmation.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.updateLayoutParams
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountBinding
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.webexport.accountconfirmation.ui.model.BaseAccountConfirmationListItem
import com.algorand.android.utils.AccountIconDrawable

class AccountConfirmationItemViewHolder(
    private val binding: ItemAccountBinding
) : RecyclerView.ViewHolder(binding.root) {

    private fun setAccountStartIconDrawable(accountIconDrawablePreview: AccountIconDrawablePreview) {
        with(binding.accountItemView) {
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                accountIconDrawablePreview = accountIconDrawablePreview,
                sizeResId = R.dimen.spacing_xxxxlarge
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

    fun bind(item: BaseAccountConfirmationListItem.AccountItem) {
        with(item.accountAssetIconNameConfiguration) {
            setAccountStartIconDrawable(accountIconDrawablePreview)
            setAccountTitleText(title)
            setAccountDescriptionText(description)
        }
        binding.root.apply {
            item.topMarginResId?.let {
                updateLayoutParams<ViewGroup.MarginLayoutParams> {
                    setMargins(0, resources.getDimensionPixelSize(it), 0, 0)
                }
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): AccountConfirmationItemViewHolder {
            val binding = ItemAccountBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return AccountConfirmationItemViewHolder(binding)
        }
    }
}
