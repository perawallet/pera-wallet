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

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.text.SpannableStringBuilder
import android.util.AttributeSet
import androidx.appcompat.content.res.AppCompatResources
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectTransactionInfoBinding
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.TransactionRequestAssetInformation
import com.algorand.android.models.TransactionRequestTransactionInfo
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.addUnnamedAssetName
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setDrawable
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

    fun initTransactionInfo(transactionInfo: TransactionRequestTransactionInfo?) {
        if (transactionInfo == null) return
        with(transactionInfo) {
            binding.assetDeletionRequestWarningTextView.isVisible = showDeletionWarning
            initFromAddress(fromDisplayedAddress, fromAccountIcon)
            initToAddress(toDisplayedAddress)
            initAssetInformation(assetInformation)
            initAccountBalance(accountBalance, assetInformation)
            initRekeyToAddress(rekeyToAccountAddress, isLocalAccountSigner)
            initCloseToAddress(closeToAccountAddress, isLocalAccountSigner)
            initAssetCloseToAddress(assetCloseToAddress, assetInformation?.shortName)
            initAssetName(assetName, isAssetUnnamed)
            initUnitName(assetUnitName, isAssetUnnamed)
        }
    }

    private fun initAssetName(assetName: String?, isAssetUnnamed: Boolean) {
        when {
            isAssetUnnamed -> {
                with(binding) {
                    assetTextView.text = SpannableStringBuilder().apply { addUnnamedAssetName(context) }
                    assetNameGroup.show()
                }
            }
            !assetName.isNullOrBlank() -> {
                with(binding) {
                    assetTextView.text = assetName
                    assetNameGroup.show()
                }
            }
        }
    }

    private fun initUnitName(assetUnitName: String?, isAssetUnnamed: Boolean) {
        when {
            isAssetUnnamed -> {
                with(binding) {
                    assetUnitNameTextView.text = SpannableStringBuilder().apply { addUnnamedAssetName(context) }
                    unitNameGroup.show()
                }
            }
            !assetUnitName.isNullOrBlank() -> {
                with(binding) {
                    assetUnitNameTextView.text = assetUnitName
                    unitNameGroup.show()
                }
            }
        }
    }

    private fun initFromAddress(
        displayedAddress: BaseWalletConnectDisplayedAddress?,
        accountIcon: AccountIcon?
    ) {
        if (displayedAddress != null) {
            with(binding) {
                fromAccountNameTextView.apply {
                    text = displayedAddress.displayValue
                    isSingleLine = displayedAddress.isSingleLine == true
                }
                if (accountIcon != null) {
                    fromAccountTypeImageView.setAccountIcon(accountIcon, R.dimen.spacing_xxsmall)
                }
                fromGroup.show()
            }
        }
    }

    private fun initToAddress(displayedAddress: String?) {
        if (!displayedAddress.isNullOrBlank()) {
            binding.toAccountNameTextView.text = displayedAddress
            binding.toGroup.show()
        }
    }

    private fun initAssetInformation(assetInformation: TransactionRequestAssetInformation?) {
        assetInformation?.let {
            with(binding) {
                if (assetInformation.isVerified == true) {
                    assetNameTextView.setDrawable(start = AppCompatResources.getDrawable(context, R.drawable.ic_shield))
                }
                assetNameTextView.text = assetInformation.shortName
                assetIdTextView.text = assetInformation.assetId.toString()
                assetGroup.show()
            }
        }
    }

    private fun initAccountBalance(balance: BigInteger?, assetInformation: TransactionRequestAssetInformation?) {
        balance?.let {
            with(binding) {
                val formattedBalance = context?.getXmlStyledString(
                    stringResId = R.string.amount_with_asset_short_name,
                    replacementList = listOf(
                        "amount" to balance.formatAmount(assetInformation?.decimals ?: ALGO_DECIMALS),
                        "asset_short_name" to assetInformation?.shortName.orEmpty()
                    )
                )
                accountBalanceTextView.text = formattedBalance
                accountBalanceGroup.show()
            }
        }
    }

    private fun initRekeyToAddress(address: BaseWalletConnectDisplayedAddress?, isLocalAccountSigner: Boolean) {
        if (!address?.displayValue.isNullOrBlank()) {
            with(binding) {
                rekeyToTextView.apply {
                    text = address?.displayValue
                    isSingleLine = address?.isSingleLine == true
                }
                rekeyGroup.show()
                rekeyToWarningTextView.isVisible = isLocalAccountSigner
            }
        }
    }

    private fun initCloseToAddress(address: BaseWalletConnectDisplayedAddress?, isLocalAccountSigner: Boolean) {
        if (!address?.displayValue.isNullOrBlank()) {
            with(binding) {
                remainderCloseToTextView.apply {
                    text = address?.displayValue
                    isSingleLine = address?.isSingleLine == true
                }
                remainderGroup.show()
                remainderCloseToWarningTextView.isVisible = isLocalAccountSigner
            }
        }
    }

    private fun initAssetCloseToAddress(address: BaseWalletConnectDisplayedAddress?, assetShortName: String?) {
        if (!address?.displayValue.isNullOrBlank()) {
            with(binding) {
                closeAssetToWarningTextView.text = root.context.getString(
                    R.string.this_transaction_is_sending_asset,
                    assetShortName
                )
                closeAssetToTextView.apply {
                    text = address?.displayValue
                    isSingleLine = address?.isSingleLine == true
                }
                closeAssetToGroup.show()
            }
        }
    }

    private fun initRootLayout() {
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_large))
    }
}
