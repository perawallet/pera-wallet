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
import android.text.SpannableStringBuilder
import android.text.style.AbsoluteSizeSpan
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectTransactionShortAmountViewBinding
import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.WalletConnectTransactionAmount
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.addUnnamedAssetName
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger

class WalletConnectSingleTransactionAssetInfoView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectTransactionShortAmountViewBinding::inflate)

    fun setTransactionShortAmount(walletConnectTransactionAmount: WalletConnectTransactionAmount) {
        with(walletConnectTransactionAmount) {
            when {
                transactionAmount != null -> {
                    setTransactionAmountGroup(
                        transactionAmount,
                        assetDecimal,
                        assetShortName,
                        formattedSelectedCurrencyValue
                    )
                }
                assetName != null -> setAssetNameAndIdGroup(assetName, isVerified, assetId)
                isAssetUnnamed -> setAssetNameAsUnnamed()
                applicationId != null -> setAppIdGroup(applicationId)
                appOnComplete != null -> setAppOnCompleteGroup(appOnComplete)
            }
        }
    }

    private fun setTransactionAmountGroup(
        transactionAmount: BigInteger,
        assetDecimal: Int?,
        assetShortName: String?,
        formattedSelectedCurrencyValue: String?
    ) {
        with(binding) {
            val formattedAmount = transactionAmount.formatAmount(assetDecimal ?: ALGO_DECIMALS)
            val assetShortNameTextSize = context.resources.getDimensionPixelSize(R.dimen.text_size_19)
            // TODO: 13.01.2022 Find a better way to format this text 
            assetAmountTextView.text = context?.getXmlStyledString(
                stringResId = R.string.formatted_amount_with_asset_name_txn,
                replacementList = listOf(
                    "asset_amount" to formattedAmount,
                    "asset_short_name" to assetShortName.orEmpty()
                ),
                customAnnotations = listOf(
                    "text_size" to AbsoluteSizeSpan(assetShortNameTextSize)
                )
            )
            assetCurrencyAmountTextView.setTextAndVisibility(formattedSelectedCurrencyValue)
            assetAmountAndCurrencyValueGroup.show()
        }
    }

    private fun setAssetNameAndIdGroup(
        assetName: String?,
        isVerified: Boolean?,
        assetId: Long?,
    ) {
        with(binding) {
            assetNameTextView.text = assetName
            if (isVerified == true) {
                val verifiedIcon = ContextCompat.getDrawable(context, R.drawable.ic_shield)
                assetNameTextView.setDrawable(start = verifiedIcon)
            }
            if (assetId != null) assetIdTextView.text = assetId.toString()
            assetNameAndIdGroup.show()
        }
    }

    private fun setAssetNameAsUnnamed() {
        with(binding) {
            assetNameTextView.text = SpannableStringBuilder().apply { addUnnamedAssetName(context) }
            assetNameAndIdGroup.show()
        }
    }

    private fun setAppIdGroup(applicationId: Long?) {
        with(binding) {
            appIdTextView.text = resources.getString(R.string.id_with_hash_tag, applicationId)
            appIdGroup.show()
        }
    }

    private fun setAppOnCompleteGroup(appOnComplete: BaseAppCallTransaction.AppOnComplete) {
        with(binding) {
            appOnCompleteTextView.setText(appOnComplete.displayTextResId)
            appOnCompleteGroup.show()
        }
    }
}
