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
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectTransactionSummaryViewBinding
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionListItem
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger

class WalletConnectTransactionSummaryCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectTransactionSummaryViewBinding::inflate)

    init {
        initRootLayout()
    }

    fun initTransaction(
        singleTransaction: WalletConnectTransactionListItem.SingleTransactionItem,
        listener: OnShowDetailClickListener
    ) {
        with(singleTransaction.transactionSummary) {
            setAccountInformationText(
                accountName,
                accountBalance,
                assetDecimal,
                assetShortName,
                accountIcon
            )
            setTitleText(transactionAmount, assetDecimal, assetShortName, summaryTitle)
            setCurrencyText(formattedSelectedCurrencyValue)
            setWarningInfo(showWarning)
            with(binding.showTransactionDetailButton) {
                setText(showMoreButtonText)
                setOnClickListener { listener.onShowDetailClick(singleTransaction.transaction) }
            }
        }
    }

    private fun setWarningInfo(showWarning: Boolean) {
        binding.warningImageView.isVisible = showWarning
    }

    fun setTitleText(
        transactionAmount: BigInteger?,
        assetDecimal: Int?,
        shortName: String?,
        summaryTitle: AnnotatedString?
    ) {
        when {
            transactionAmount != null -> setTransactionAmountGroup(transactionAmount, assetDecimal, shortName)
            summaryTitle != null -> setSummaryTitleGroup(summaryTitle)
        }
    }

    private fun setTransactionAmountGroup(
        transactionAmount: BigInteger,
        assetDecimal: Int?,
        shortName: String?
    ) {
        with(binding.transactionsAmountTextView) {
            val formattedBalance = transactionAmount.formatAmount(assetDecimal ?: ALGO_DECIMALS)
            text = context?.getXmlStyledString(
                stringResId = R.string.amount_with_asset_short_name,
                replacementList = listOf(
                    "amount" to formattedBalance,
                    "asset_short_name" to shortName.orEmpty()
                )
            )
            changeTextAppearance(R.style.TextAppearance_Body_Large_Mono)
        }
    }

    private fun setSummaryTitleGroup(summaryTitle: AnnotatedString) {
        with(binding.transactionsAmountTextView) {
            text = context?.getXmlStyledString(summaryTitle)
            changeTextAppearance(R.style.TextAppearance_Body_Large_Sans)
        }
    }

    private fun setAccountInformationText(
        accountName: String?,
        accountBalance: BigInteger?,
        assetDecimal: Int?,
        shortName: String?,
        accountIcon: AccountIcon?
    ) {
        with(binding) {
            if (accountIcon != null) {
                transactionAccountTypeImageView.apply {
                    setAccountIcon(accountIcon, R.dimen.spacing_xxsmall)
                    show()
                }
            }
            transactionAccountNameTextView.setTextAndVisibility(accountName)
            if (accountBalance != null) {
                val formattedBalance = accountBalance.formatAmount(assetDecimal ?: ALGO_DECIMALS)
                accountBalanceTextView.setTextAndVisibility(
                    context?.getXmlStyledString(
                        stringResId = R.string.amount_with_asset_short_name,
                        replacementList = listOf(
                            "amount" to formattedBalance,
                            "asset_short_name" to shortName.orEmpty()
                        )
                    ).toString()
                )
                dotImageView.show()
            }
        }
    }

    private fun setCurrencyText(formattedSelectedCurrencyValue: String?) {
        binding.transactionAmountCurrencyValue.setTextAndVisibility(formattedSelectedCurrencyValue)
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_passphrase_group_background)
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_large))
    }

    fun interface OnShowDetailClickListener {
        fun onShowDetailClick(transaction: BaseWalletConnectTransaction)
    }
}
