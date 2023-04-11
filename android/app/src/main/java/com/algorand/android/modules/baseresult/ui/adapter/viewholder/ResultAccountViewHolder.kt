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

package com.algorand.android.modules.baseresult.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemResultAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.baseresult.ui.model.ResultListItem
import com.algorand.android.utils.AccountIconDrawable

class ResultAccountViewHolder(
    private val binding: ItemResultAccountBinding,
    private val listener: Listener
) : BaseViewHolder<ResultListItem>(binding.root) {

    override fun bind(item: ResultListItem) {
        if (item !is ResultListItem.AccountItem) return
        with(binding.accountItemView) {
            setTitleText(item.accountDisplayName.getAccountPrimaryDisplayName())
            setDescriptionText(item.accountDisplayName.getAccountSecondaryDisplayName(resources))
            val accountIconSize = resources.getDimension(R.dimen.account_icon_size_large).toInt()
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                accountIconResource = item.accountIconResource,
                size = accountIconSize
            )
            setStartIconDrawable(accountIconDrawable)
            setOnLongClickListener {
                listener.onAccountLongPressed(item.accountDisplayName.getRawAccountAddress())
                true
            }
        }
    }

    fun interface Listener {
        fun onAccountLongPressed(accountAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): ResultAccountViewHolder {
            val binding = ItemResultAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ResultAccountViewHolder(binding, listener)
        }
    }
}
