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
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.TransactionSymbol
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getXmlStyledString
import java.math.BigInteger

// TODO: 30.12.2021 We must create own model class for custom views
class AlgorandAmountView @JvmOverloads constructor(
    context: Context,
    private val attrs: AttributeSet? = null
) : AppCompatTextView(context, attrs) {

    private var isOperatorShown: Boolean = false

    init {
        loadAttrs()
    }

    private fun loadAttrs() {
        context.obtainStyledAttributes(attrs, R.styleable.CustomAmountView).use { attrs ->
            isOperatorShown = attrs.getBoolean(R.styleable.CustomAmountView_showOperator, false)
        }
    }

    fun setAmountTextAppearance(textAppearance: Int) {
        if (textAppearance != -1) {
            changeTextAppearance(textAppearance)
        }
    }

    private fun setAmountTextColor(textColor: Int) {
        setTextColor(textColor)
    }

    private fun setColorAccordingToTransactionType(symbol: TransactionSymbol?) {
        val color = when (symbol) {
            TransactionSymbol.NEGATIVE -> ContextCompat.getColor(context, R.color.transaction_amount_negative_color)
            TransactionSymbol.POSITIVE -> ContextCompat.getColor(context, R.color.transaction_amount_positive_color)
            null -> ContextCompat.getColor(context, R.color.primary_text_color)
        }
        setAmountTextColor(color)
    }

    fun setAmountAsFee(amount: Long?) {
        setColorAccordingToTransactionType(null)
        val formattedAmount = amount.formatAmount(ALGO_DECIMALS)
        val assetShortName = ALGOS_SHORT_NAME
        text = context.getXmlStyledString(
            stringResId = R.string.amount_with_asset,
            replacementList = listOf(
                "asset_amount" to formattedAmount,
                "asset_short_name" to assetShortName
            )
        )
    }

    fun setAmountAsReward(amount: Long?, decimal: Int, assetInformation: AssetInformation?) {
        setColorAccordingToTransactionType(TransactionSymbol.POSITIVE)
        val formattedAmount = amount.formatAmount(decimal)
        val assetShortName = assetInformation?.shortName.toString()
        val xmlStyledAmount = context.getXmlStyledString(
            stringResId = R.string.amount_with_asset,
            replacementList = listOf(
                "asset_amount" to formattedAmount,
                "asset_short_name" to assetShortName
            )
        )
        text = StringBuilder().apply {
            append(context.getString(R.string.plus))
            append(xmlStyledAmount)
        }
    }

    fun setAmount(
        amount: BigInteger?,
        decimal: Int?,
        transactionSymbol: TransactionSymbol? = null,
        assetShortName: String?
    ) {
        setColorAccordingToTransactionType(transactionSymbol)
        val formattedAmount = amount.formatAmount(decimal ?: ALGO_DECIMALS)
        val operatorSign = when (transactionSymbol) {
            TransactionSymbol.POSITIVE -> context.getString(R.string.plus)
            TransactionSymbol.NEGATIVE -> context.getString(R.string.minus)
            else -> ""
        }
        val xmlStyledAmount = context.getXmlStyledString(
            stringResId = R.string.amount_with_asset,
            replacementList = listOf(
                "asset_amount" to formattedAmount,
                "asset_short_name" to assetShortName.toString()
            )
        )
        text = StringBuilder().apply {
            if (isOperatorShown) {
                append(operatorSign)
            }
            append(xmlStyledAmount)
        }
    }

    fun setAmount(
        amount: BigInteger?,
        transactionSymbol: TransactionSymbol? = null,
        assetInformation: AssetInformation
    ) {
        setAmount(amount, assetInformation.decimals, transactionSymbol, assetInformation.shortName)
    }
}
