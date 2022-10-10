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

package com.algorand.android.ui.ledgersearch.ledgerinformation

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemLedgerInformationAccountBinding
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.utils.AccountIconDrawable

class AccountItemViewHolder(
    private val binding: ItemLedgerInformationAccountBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(accountItem: LedgerInformationListItem.AccountItem) {
        with(accountItem) {
            with(binding.accountItemView) {
                val accountIconDrawable = AccountIconDrawable.create(
                    context = context,
                    accountIconResource = accountIconResource,
                    size = resources.getDimensionPixelSize(R.dimen.account_icon_size_large)
                )
                setStartIconDrawable(accountIconDrawable)
                setPrimaryValueText(portfolioValue)
                setTitleText(accountDisplayName.getDisplayTextOrAccountShortenedAddress())
                setDescriptionText(accountDisplayName.getAccountShortenedAddressOrAccountType(resources))
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): AccountItemViewHolder {
            val binding =
                ItemLedgerInformationAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountItemViewHolder(binding)
        }
    }
}
