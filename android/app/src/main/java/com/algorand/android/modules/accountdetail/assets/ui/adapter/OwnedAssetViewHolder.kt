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
import androidx.core.view.isVisible
import com.algorand.android.databinding.ItemAccountAssetViewBinding
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.BaseViewHolder

class OwnedAssetViewHolder(
    private val binding: ItemAccountAssetViewBinding
) : BaseViewHolder<AccountDetailAssetsItem>(binding.root) {

    override fun bind(item: AccountDetailAssetsItem) {
        if (item !is AccountDetailAssetsItem.BaseAssetItem.OwnedAssetItem) return
        with(binding) {
            with(item) {
                val formattedShortName = shortName.getName(root.resources)
                val formattedFullName = name.getName(root.resources)
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
