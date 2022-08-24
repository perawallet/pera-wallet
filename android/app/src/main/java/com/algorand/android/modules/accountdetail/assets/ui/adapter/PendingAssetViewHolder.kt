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

package com.algorand.android.modules.accountdetail.assets.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemAccountPendingAssetViewBinding
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.BaseViewHolder

class PendingAssetViewHolder(
    private val binding: ItemAccountPendingAssetViewBinding
) : BaseViewHolder<AccountDetailAssetsItem>(binding.root) {

    override fun bind(item: AccountDetailAssetsItem) {
        if (item !is AccountDetailAssetsItem.BaseAssetItem.BasePendingAssetItem) return
        with(binding) {
            with(item) {
                val formattedShortName = shortName.getName(root.resources)
                val formattedFullName = name.getName(root.resources)
                actionDescriptionTextView.setText(actionDescriptionResId)
                assetNameTextView.apply {
                    setupUI(isVerified, formattedShortName, formattedFullName, item.id, isAlgo)
                    showProgressBar()
                }
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): PendingAssetViewHolder {
            val binding = ItemAccountPendingAssetViewBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return PendingAssetViewHolder(binding)
        }
    }
}
