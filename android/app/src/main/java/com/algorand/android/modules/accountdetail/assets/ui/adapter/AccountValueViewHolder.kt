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
 *
 */

package com.algorand.android.modules.accountdetail.assets.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountValueBinding
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.models.BaseViewHolder

class AccountValueViewHolder(
    private val binding: ItemAccountValueBinding
) : BaseViewHolder<AccountDetailAssetsItem>(binding.root) {

    companion object {
        fun create(parent: ViewGroup): AccountValueViewHolder {
            val binding = ItemAccountValueBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountValueViewHolder(binding)
        }
    }

    override fun bind(item: AccountDetailAssetsItem) {
        if (item !is AccountDetailAssetsItem.AccountPortfolioItem) return
        with(binding) {
            primaryValueTextView.text = item.accountPrimaryFormattedParityValue
            secondaryValueTextView.text = binding.root.resources.getString(
                R.string.approximate_currency_value,
                item.accountSecondaryFormattedParityValue
            )
        }
    }
}
