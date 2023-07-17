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

package com.algorand.android.modules.baseledgeraccountselection.accountinformation.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemLedgerInformationAccountBinding
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.toShortenedAddress

class CanSignedByItemViewHolder(
    private val binding: ItemLedgerInformationAccountBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(canSignedByItem: LedgerInformationListItem.CanSignedByItem) {
        with(canSignedByItem) {
            with(binding.accountItemView) {
                val accountIconDrawable = AccountIconDrawable.create(
                    context = context,
                    accountIconDrawablePreview = accountIconDrawablePreview,
                    sizeResId = R.dimen.account_icon_size_large
                )
                setStartIconDrawable(accountIconDrawable)
                setTitleText(accountPublicKey.toShortenedAddress())
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): CanSignedByItemViewHolder {
            val binding =
                ItemLedgerInformationAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return CanSignedByItemViewHolder(binding)
        }
    }
}
