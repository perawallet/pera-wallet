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

package com.algorand.android.modules.transaction.detail.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemTransactionAssetInformationBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem

class TransactionAssetInformationViewHolder(
    private val binding: ItemTransactionAssetInformationBinding
) : BaseViewHolder<TransactionDetailItem>(binding.root) {

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.StandardTransactionItem.AssetInformationItem) return
        with(binding) {
            assetInformationLabelTextView.setText(item.labelTextRes)
            assetSecondaryTextView.text = root.resources.getString(
                R.string.pair_value_format_with_coma,
                item.assetShortName.getName(root.resources),
                item.assetId
            )
            assetPrimaryTextView.text = item.assetFullName.getName(root.resources)
        }
    }

    companion object {
        fun create(parent: ViewGroup): TransactionAssetInformationViewHolder {
            val binding = ItemTransactionAssetInformationBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return TransactionAssetInformationViewHolder(binding)
        }
    }
}
