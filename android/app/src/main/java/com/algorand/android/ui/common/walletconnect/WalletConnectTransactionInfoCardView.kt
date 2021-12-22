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
import androidx.annotation.StringRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectTransactionInfoBinding
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectAssetInformation
import com.algorand.android.models.WalletConnectTransactionInfo
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger

class WalletConnectTransactionInfoCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectTransactionInfoBinding::inflate)

    init {
        initRootLayout()
    }

    fun initTransactionInfo(transactionInfo: WalletConnectTransactionInfo) {
        binding.root.visibility = View.VISIBLE
        binding.assetDeletionRequestWarningTextView.isVisible = transactionInfo.showAssetDeletionWarning
        with(transactionInfo) {
            initFromAddress(fromDisplayedAddress, accountTypeImageResId)
            initAssetInformation(assetInformation, showAssetDeletionWarning)
            initAccountBalance(accountBalance, assetDecimal, assetInformation?.isAlgorand)
            initRekeyToAddress(rekeyToAccountAddress)
            initCloseToAddress(closeToAccountAddress)
            initAssetName(assetName)
            initUnitName(unitName)
        }
    }

    private fun initAssetName(assetName: String?) {
        if (!assetName.isNullOrEmpty()) {
            with(binding) {
                assetTextView.text = assetName
                assetNameGroup.visibility = VISIBLE
            }
        }
    }

    private fun initUnitName(assetUnitName: String?) {
        if (!assetUnitName.isNullOrEmpty()) {
            with(binding) {
                assetUnitNameTextView.text = assetUnitName
                unitNameGroup.visibility = VISIBLE
            }
        }
    }

    fun setCloseToLabel(@StringRes textResId: Int) {
        binding.reminderCloseToLabelTextView.setText(textResId)
    }

    fun setCloseToWarning(warningText: String) {
        binding.reminderStatusTextView.text = warningText
    }

    private fun initFromAddress(displayedAddress: BaseWalletConnectDisplayedAddress, accountTypeImageResId: Int?) {
        with(binding) {
            accountNameTextView.apply {
                text = displayedAddress.displayValue
                isSingleLine = displayedAddress.isSingleLine
            }
            if (accountTypeImageResId != null) {
                accountTypeImageView.apply {
                    setImageResource(accountTypeImageResId)
                    visibility = View.VISIBLE
                }
            }
        }
    }

    private fun initAssetInformation(
        assetInformation: WalletConnectAssetInformation?,
        showAssetDeletionMessage: Boolean
    ) {
        if (assetInformation != null) {
            with(binding) {
                assetNameTextView.setupUI(assetInformation, false)
                assetDeletionRequestWarningTextView.isVisible = showAssetDeletionMessage
                assetGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initAccountBalance(balance: BigInteger?, decimal: Int, isAlgorand: Boolean?) {
        if (balance != null) {
            with(binding) {
                accountBalanceTextView.setAmount(balance, decimal, isAlgorand ?: false)
                accountBalanceGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initRekeyToAddress(address: String?) {
        if (!address.isNullOrBlank()) {
            with(binding) {
                rekeyToTextView.text = address
                rekeyGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initCloseToAddress(address: String?) {
        if (!address.isNullOrBlank()) {
            with(binding) {
                reminderCloseToTextView.text = address
                reminderGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(resources.getDimensionPixelSize(R.dimen.keyline_1_plus_4_dp))
        updatePadding(bottom = resources.getDimensionPixelSize(R.dimen.smallshadow_bottom_padding_18dp))
    }
}
