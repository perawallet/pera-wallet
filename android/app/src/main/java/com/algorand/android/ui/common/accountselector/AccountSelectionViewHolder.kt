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

package com.algorand.android.ui.common.accountselector

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountOptionBinding
import com.algorand.android.models.AccountSelection
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.setTextAndVisibility

class AccountSelectionViewHolder(
    private val binding: ItemAccountOptionBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(accountSelection: AccountSelection, showBalance: Boolean, defaultSelectedAccountAddress: String?) {
        with(binding) {
            with(accountSelection) {
                nameTextView.text = accountDisplayName?.getAccountPrimaryDisplayName()
                if (accountIconDrawablePreview != null) {
                    val accountIconDrawable = AccountIconDrawable.create(
                        context = typeImageView.context,
                        accountIconDrawablePreview = accountIconDrawablePreview,
                        sizeResId = R.dimen.spacing_xxxxlarge
                    )
                    typeImageView.setImageDrawable(accountIconDrawable)
                }
                checkImageView.isVisible = accountAddress == defaultSelectedAccountAddress
                setupAssetCount(accountAssetCount ?: 0)
            }
        }
    }

    private fun setupAssetCount(assetCount: Int) {
        with(binding) {
            if (assetCount > 0) {
                accountAssetCountTextView.setTextAndVisibility(
                    root.resources.getQuantityString(R.plurals.account_asset_count, assetCount, assetCount)
                )
            } else {
                accountAssetCountTextView.setText(R.string.account_asset_count_zero)
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): AccountSelectionViewHolder {
            val binding = ItemAccountOptionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountSelectionViewHolder(binding)
        }
    }
}
