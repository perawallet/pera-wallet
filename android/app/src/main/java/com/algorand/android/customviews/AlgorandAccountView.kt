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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import com.algorand.android.R
import com.algorand.android.databinding.CustomAccountViewBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountIcon
import com.algorand.android.utils.viewbinding.viewBinding

class AlgorandAccountView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomAccountViewBinding::inflate)

    fun setAccount(accountCacheData: AccountCacheData) {
        with(accountCacheData) {
            val assetCount = assetsInformation.count()
            with(binding) {
                accountIconImageView.setAccountIcon(account.createAccountIcon())
                mainTextView.text = account.name
                subTextView.text = resources.getQuantityString(
                    R.plurals.account_asset_count,
                    assetCount,
                    assetCount
                )
            }
        }
    }

    fun setAccount(name: String, assetCount: Int, accountIcon: AccountIcon) {
        with(binding) {
            accountIconImageView.setAccountIcon(accountIcon)
            mainTextView.text = name
            subTextView.text = resources.getQuantityString(
                R.plurals.account_asset_count,
                assetCount,
                assetCount,
                assetCount
            )
        }
    }

    fun setAccountIcon(accountIcon: AccountIcon) {
        binding.accountIconImageView.setAccountIcon(accountIcon)
    }

    fun setAccountAddress(address: String) {
        binding.mainTextView.text = address
    }
}
