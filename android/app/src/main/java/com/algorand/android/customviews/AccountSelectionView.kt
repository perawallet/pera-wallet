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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import com.algorand.android.R
import com.algorand.android.databinding.CustomAccountSelectionViewBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.utils.viewbinding.viewBinding

class AccountSelectionView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var selectedAccount: AccountCacheData? = null

    private val binding = viewBinding(CustomAccountSelectionViewBinding::inflate)

    init {
        setBackgroundResource(R.drawable.bg_small_shadow)
    }

    fun setAccount(selectedAccount: AccountCacheData) {
        this.selectedAccount = selectedAccount
        binding.hintTextView.visibility = View.GONE
        binding.textView.text = selectedAccount.account.name
        binding.textView.visibility = View.VISIBLE
    }

    fun getAccountAddress(): String? {
        return selectedAccount?.account?.address
    }
}
