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

package com.algorand.android.modules.basefoundaccount.information.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemFoundAccountInformationAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basefoundaccount.information.ui.model.BaseFoundAccountInformationItem
import com.algorand.android.utils.AccountIconDrawable

class FoundAccountInformationAccountViewHolder(
    private val binding: ItemFoundAccountInformationAccountBinding,
    private val listener: Listener
) : BaseViewHolder<BaseFoundAccountInformationItem>(binding.root) {

    override fun bind(item: BaseFoundAccountInformationItem) {
        if (item !is BaseFoundAccountInformationItem.AccountItem) return
        with(item) {
            with(binding.accountItemView) {
                val accountIconDrawable = AccountIconDrawable.create(
                    context = context,
                    accountIconDrawablePreview = accountIconDrawablePreview,
                    sizeResId = R.dimen.account_icon_size_large
                )
                setStartIconDrawable(accountIconDrawable)
                setPrimaryValueText(formattedPrimaryValue)
                setSecondaryValueText(formattedSecondaryValue)
                setTitleText(accountDisplayName.getAccountPrimaryDisplayName())
                setDescriptionText(accountDisplayName.getAccountSecondaryDisplayName(resources))
                setOnLongClickListener {
                    listener.onAccountItemLongClick(accountDisplayName.getRawAccountAddress())
                    true
                }
            }
        }
    }

    fun interface Listener {
        fun onAccountItemLongClick(accountAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): FoundAccountInformationAccountViewHolder {
            val binding = ItemFoundAccountInformationAccountBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return FoundAccountInformationAccountViewHolder(binding, listener)
        }
    }
}
