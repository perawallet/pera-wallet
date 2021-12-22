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

package com.algorand.android.customviews

import android.content.Context
import android.content.res.ColorStateList
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.res.ResourcesCompat
import androidx.core.content.res.use
import androidx.core.view.isVisible
import androidx.core.widget.ImageViewCompat
import com.algorand.android.R
import com.algorand.android.databinding.CustomTransactionAmountTextViewBinding
import com.algorand.android.models.TransactionSymbol
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger
import kotlin.properties.Delegates

class TransactionAmountTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomTransactionAmountTextViewBinding::inflate)

    private var isAlgorand by Delegates.observable(false) { _, _, newValue ->
        binding.algoLogoImageView.isVisible = newValue
        binding.otherAssetNameTextView.isVisible = newValue.not()
    }

    private var value = BigInteger.ZERO

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        initView(attrs)
    }

    private fun initView(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.TransactionAmountTextView).use { typedArray ->

            if (typedArray.getBoolean(R.styleable.TransactionAmountTextView_showOperator, true)) {
                binding.transactionOperatorTextView.visibility = View.VISIBLE
            } else {
                binding.transactionOperatorTextView.visibility = View.GONE
            }

            val tintColor = typedArray.getColor(R.styleable.TransactionAmountTextView_defaultTintColor, NO_COLOR_RES_ID)
            if (tintColor != NO_COLOR_RES_ID) {
                ImageViewCompat.setImageTintList(binding.algoLogoImageView, ColorStateList.valueOf(tintColor))
                binding.transactionAmountTextView.setTextColor(tintColor)
                binding.otherAssetNameTextView.setTextColor(tintColor)
            }

            val iconTint = typedArray.getColor(R.styleable.TransactionAmountTextView_iconTint, NO_COLOR_RES_ID)
            if (iconTint != NO_COLOR_RES_ID) {
                ImageViewCompat.setImageTintList(binding.algoLogoImageView, ColorStateList.valueOf(iconTint))
            }

            val amountTextViewSize =
                typedArray.getDimension(R.styleable.TransactionAmountTextView_amountTextViewSize, -1f)
            if (amountTextViewSize != -1f) {
                binding.transactionOperatorTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, amountTextViewSize)
                binding.transactionAmountTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, amountTextViewSize)
            }

            val otherAssetViewSize =
                typedArray.getDimension(R.styleable.TransactionAmountTextView_otherAssetTextViewSize, -1f)
            if (otherAssetViewSize != -1f) {
                binding.otherAssetNameTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, otherAssetViewSize)
                binding.otherAssetNameTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, otherAssetViewSize)
            }

            val algoLogoSize =
                typedArray.getDimensionPixelSize(R.styleable.TransactionAmountTextView_algoLogoViewSize, -1)
            if (algoLogoSize != -1) {
                binding.algoLogoImageView.layoutParams =
                    binding.algoLogoImageView.layoutParams.apply {
                        height = algoLogoSize
                        width = algoLogoSize
                    }
            }

            val amountFont =
                typedArray.getResourceId(R.styleable.TransactionAmountTextView_amountFontFamily, -1)
            if (amountFont != -1) {
                binding.transactionAmountTextView.typeface = ResourcesCompat.getFont(context, amountFont)
            }

            val otherAssetFont =
                typedArray.getResourceId(R.styleable.TransactionAmountTextView_otherAssetFontFamily, -1)
            if (otherAssetFont != -1) {
                binding.transactionAmountTextView.typeface = ResourcesCompat.getFont(context, otherAssetFont)
            }
        }
    }

    private fun setOperatorAccordingToTransactionType(microAlgosValue: BigInteger?, symbol: TransactionSymbol?) {
        if (binding.transactionOperatorTextView.isVisible.not()) {
            return
        }
        when (symbol) {
            TransactionSymbol.NEGATIVE -> {
                binding.transactionOperatorTextView.text = resources.getString(R.string.minus)
            }
            TransactionSymbol.POSITIVE -> {
                binding.transactionOperatorTextView.text = resources.getString(R.string.plus)
            }
            null -> {
                binding.transactionOperatorTextView.text = ""
            }
        }
    }

    fun setAmount(amount: Long, decimal: Int, isAlgorand: Boolean, otherAssetName: String?) {
        setAmount(BigInteger.valueOf(amount), decimal, isAlgorand, otherAssetName)
    }

    fun setAmount(
        amount: Long,
        decimal: Int,
        isAlgorand: Boolean,
        transactionSymbol: TransactionSymbol?,
        otherAssetName: String?
    ) {
        setAmount(BigInteger.valueOf(amount), decimal, isAlgorand, transactionSymbol, otherAssetName)
    }

    fun setAmount(amount: BigInteger?, decimal: Int, isAlgorand: Boolean, otherAssetName: String?) {
        this.isAlgorand = isAlgorand
        value = amount ?: BigInteger.ZERO
        with(binding) {
            transactionAmountTextView.text = value.formatAmount(decimal)
            otherAssetNameTextView.text = otherAssetName
            changeBalanceGroupVisibility(true)
        }
    }

    fun setAssetName(assetName: String, isAlgorand: Boolean) {
        this.isAlgorand = isAlgorand
        with(binding) {
            otherAssetNameTextView.text = assetName
            changeBalanceGroupVisibility(false)
        }
    }

    fun setAmount(
        amount: BigInteger?,
        decimal: Int,
        isAlgorand: Boolean,
        transactionSymbol: TransactionSymbol?,
        otherAssetName: String?
    ) {
        setAmount(amount, decimal, isAlgorand, otherAssetName)
        setOperatorAccordingToTransactionType(amount, transactionSymbol)
    }

    fun setAmount(
        amount: BigInteger?,
        formattedAmount: String,
        isAlgorand: Boolean,
        transactionSymbol: TransactionSymbol?,
        otherAssetName: String?
    ) {
        this.isAlgorand = isAlgorand
        value = amount
        with(binding) {
            transactionAmountTextView.text = formattedAmount
            otherAssetNameTextView.text = otherAssetName
            changeBalanceGroupVisibility(true)
        }
        setOperatorAccordingToTransactionType(amount, transactionSymbol)
    }

    fun setAssetName(unitName: String?) {
        with(binding) {
            transactionAmountTextView.text = unitName ?: resources.getString(R.string.unnamed)
            otherAssetNameTextView.visibility = GONE
            algoLogoImageView.visibility = GONE
            transactionOperatorTextView.visibility = GONE
        }
    }

    private fun changeBalanceGroupVisibility(isVisible: Boolean) {
        with(binding) {
            transactionOperatorTextView.isVisible = isVisible
            transactionAmountTextView.isVisible = isVisible
        }
    }

    companion object {
        private const val NO_COLOR_RES_ID = -2
    }
}
