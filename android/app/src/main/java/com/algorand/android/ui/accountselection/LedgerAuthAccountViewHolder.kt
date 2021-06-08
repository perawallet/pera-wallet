/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.accountselection

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemLedgerAuthAccountBinding
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.toShortenedAddress

class LedgerAuthAccountViewHolder(
    private val binding: ItemLedgerAuthAccountBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(accountSelectionListItem: AccountSelectionListItem) {
        with(accountSelectionListItem) {
            binding.nameTextView.apply {
                text = account.address.toShortenedAddress()
                setDrawable(start = AppCompatResources.getDrawable(context, accountImageResource))
            }

            // clear all views
            binding.assetBalanceLayout.removeAllViews()

            assetInformationList.forEach { assetInformation ->
                binding.assetBalanceLayout.addAssetBalanceView(assetInformation)
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): LedgerAuthAccountViewHolder {
            val binding = ItemLedgerAuthAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LedgerAuthAccountViewHolder(binding)
        }
    }
}
