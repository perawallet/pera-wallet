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
import com.algorand.android.databinding.CustomWalletConnectTransactionShortDetailViewBinding
import com.algorand.android.models.WalletConnectTransactionShortDetail
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectSingleTransactionShortDetailView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectTransactionShortDetailViewBinding::inflate)

    fun setTransactionShortDetail(
        walletConnectTransactionShortDetail: WalletConnectTransactionShortDetail,
        listener: Listener
    ) {
        with(walletConnectTransactionShortDetail) {
            with(binding) {
                val feeText = resources.getString(
                    R.string.asset_short_name_with_amount,
                    fee.formatAmount(ALGO_DECIMALS),
                    ALGOS_SHORT_NAME
                )
                networkFeeTextView.text = feeText
                accountNameTextView.text = accountName
                if (accountIcon != null) {
                    accountTypeImageView.setAccountIcon(accountIcon, R.dimen.spacing_xxsmall)
                }
                showTransactionDetailButton.setOnClickListener { listener.onShowTransactionDetailClick() }
                if (warningCount != null) {
                    warningTextView.setTextAndVisibility(
                        resources.getQuantityString(R.plurals.warning_with_count, warningCount, warningCount)
                    )
                }
                if (accountBalance != null) {
                    val accountBalanceText = context?.getXmlStyledString(
                        stringResId = R.string.amount_with_asset_short_name,
                        replacementList = listOf(
                            "amount" to accountBalance.formatAmount(decimal),
                            "asset_short_name" to assetShortName.orEmpty()
                        )
                    ).toString()
                    accountAssetBalanceTextView.setTextAndVisibility(accountBalanceText)
                }
            }
        }
    }

    interface Listener {
        fun onShowTransactionDetailClick()
    }
}
