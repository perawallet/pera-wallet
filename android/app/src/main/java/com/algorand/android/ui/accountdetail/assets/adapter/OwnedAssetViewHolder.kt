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

package com.algorand.android.ui.accountdetail.assets.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemAccountAssetViewBinding
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.utils.formatAsAlgoAmount

class OwnedAssetViewHolder(
    private val binding: ItemAccountAssetViewBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(assetItem: AccountDetailAssetsItem.BaseAssetItem.OwnedAssetItem) {
        with(binding) {
            with(assetItem) {
                val formattedShortName = shortName.getName(root.resources)
                val formattedFullName = name.getName(root.resources)

                // TODO: 12.04.2022 Move this logic into use case layer while creating this object 
                val formattedAmount = if (isAlgo) formattedAmount.formatAsAlgoAmount() else formattedAmount
                assetNameTextView.setupUI(isVerified, formattedShortName, formattedFullName, id, isAlgo)
                amountTextView.text = formattedAmount
                currencyTextView.text = formattedDisplayedCurrencyValue
                currencyTextView.isVisible = isAmountInDisplayedCurrencyVisible
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): OwnedAssetViewHolder {
            val binding = ItemAccountAssetViewBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return OwnedAssetViewHolder(binding)
        }
    }
}
