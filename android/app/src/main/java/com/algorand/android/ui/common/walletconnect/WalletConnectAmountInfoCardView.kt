/*
 * Copyright 2019 Algorand, Inc.
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

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectAmountInfoCardBinding
import com.algorand.android.models.WalletConnectAmountInfo
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger

class WalletConnectAmountInfoCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectAmountInfoCardBinding::inflate)

    init {
        initRootLayout()
    }

    fun initAmountInfo(amountInfo: WalletConnectAmountInfo) {
        with(amountInfo) {
            initAmount(amount, decimal)
            initToAddress(toAccountAddress)
            initFee(fee)
        }
    }

    private fun initAmount(amount: BigInteger?, decimal: Int) {
        if (amount != null) {
            with(binding) {
                amountBalanceGroup.visibility = View.VISIBLE
                amountTextView.setAmount(amount, decimal, false)
            }
        }
    }

    private fun initToAddress(address: String?) {
        if (!address.isNullOrBlank()) {
            with(binding) {
                toAccountNameTextView.text = address
                toAddressGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initFee(fee: Long) {
        with(binding) {
            feeTextView.setAmount(fee, ALGO_DECIMALS, true)
            feeWarningTextView.isVisible = fee > MIN_FEE
        }
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(resources.getDimensionPixelSize(R.dimen.keyline_1_plus_4_dp))
        updatePadding(bottom = resources.getDimensionPixelSize(R.dimen.smallshadow_bottom_padding_18dp))
    }
}
