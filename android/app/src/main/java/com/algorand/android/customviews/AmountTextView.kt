/*
 * Copyright 2019 Algorand, Inc.
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
import android.content.res.ColorStateList
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import androidx.core.content.res.use
import androidx.core.view.isVisible
import androidx.core.widget.ImageViewCompat
import com.algorand.android.R
import com.algorand.android.databinding.CustomAlgoTextViewBinding
import com.algorand.android.models.TransactionSymbol
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigInteger
import kotlin.properties.Delegates

class AmountTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var isAlgorand by Delegates.observable(false, { _, _, newValue ->
        binding.algoCurrencyLogoImageView.isVisible = newValue
    })

    private var value = BigInteger.ZERO

    private val binding = viewBinding(CustomAlgoTextViewBinding::inflate)

    init {
        initView(attrs)
    }

    private fun initView(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.AmountTextView).use { typedArray ->
            if (typedArray.getBoolean(R.styleable.AmountTextView_showOperator, true)) {
                binding.algoOperatorTextView.visibility = View.VISIBLE
            } else {
                binding.algoOperatorTextView.visibility = View.GONE
            }

            val tintColor = typedArray.getColor(R.styleable.AmountTextView_defaultTintColor, NO_COLOR_RES_ID)
            if (tintColor != NO_COLOR_RES_ID) {
                ImageViewCompat.setImageTintList(binding.algoCurrencyLogoImageView, ColorStateList.valueOf(tintColor))
                binding.algoAmountTextView.setTextColor(tintColor)
                setOperatorColor(tintColor)
            }

            val algoTextViewSize =
                typedArray.getDimension(R.styleable.AmountTextView_algoTextViewSize, -1f)
            if (algoTextViewSize != -1f) {
                binding.algoOperatorTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, algoTextViewSize)
                binding.algoAmountTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, algoTextViewSize)
            }
            val algoTextViewLogoSize =
                typedArray.getDimensionPixelSize(R.styleable.AmountTextView_algoLogoViewSize, -1)
            if (algoTextViewLogoSize != -1) {
                binding.algoCurrencyLogoImageView.layoutParams = binding.algoCurrencyLogoImageView.layoutParams.apply {
                    height = algoTextViewLogoSize
                    width = algoTextViewLogoSize
                }
            }

            val algoDefaultFont =
                typedArray.getResourceId(R.styleable.AmountTextView_algoFontFamily, -1)
            if (algoDefaultFont != -1) {
                binding.algoAmountTextView.typeface = ResourcesCompat.getFont(context, algoDefaultFont)
            }
        }
    }

    private fun setOperatorAccordingToTransactionType(microAlgosValue: BigInteger?, symbol: TransactionSymbol?) {
        if (binding.algoOperatorTextView.isVisible.not()) {
            return
        }
        when (symbol) {
            TransactionSymbol.NEGATIVE -> {
                binding.algoOperatorTextView.text = resources.getString(R.string.minus)
            }
            TransactionSymbol.POSITIVE -> {
                binding.algoOperatorTextView.text = resources.getString(R.string.plus)
            }
            null -> {
                binding.algoOperatorTextView.text = ""
            }
        }
    }

    private fun setColorAccordingToTransactionType(microAlgosValue: BigInteger?, symbol: TransactionSymbol?) {
        when (symbol) {
            TransactionSymbol.NEGATIVE -> {
                val payColor = ContextCompat.getColor(context, R.color.orange_E0)
                ImageViewCompat.setImageTintList(binding.algoCurrencyLogoImageView, ColorStateList.valueOf(payColor))
                binding.algoAmountTextView.setTextColor(payColor)
                setOperatorColor(payColor)
            }
            TransactionSymbol.POSITIVE -> {
                val requestColor = ContextCompat.getColor(context, R.color.green_0D)
                ImageViewCompat.setImageTintList(
                    binding.algoCurrencyLogoImageView, ColorStateList.valueOf(requestColor)
                )
                binding.algoAmountTextView.setTextColor(requestColor)
                setOperatorColor(requestColor)
            }
            null -> {
                ImageViewCompat.setImageTintList(binding.algoCurrencyLogoImageView, null)
                binding.algoAmountTextView.setTextColor(ContextCompat.getColor(context, R.color.primaryTextColor))
            }
        }
    }

    fun getValueInMicroAlgos(): BigInteger {
        return value
    }

    fun tintView(colorResId: Int) {
        val tintColor = ContextCompat.getColor(context, colorResId)
        ImageViewCompat.setImageTintList(binding.algoCurrencyLogoImageView, ColorStateList.valueOf(tintColor))
        binding.algoAmountTextView.setTextColor(tintColor)
        setOperatorColor(tintColor)
    }

    private fun setOperatorColor(color: Int) {
        if (binding.algoOperatorTextView.isVisible) {
            binding.algoOperatorTextView.setTextColor(color)
        }
    }

    fun setAmount(amount: Long, decimal: Int, isAlgorand: Boolean) {
        setAmount(BigInteger.valueOf(amount), decimal, isAlgorand)
    }

    fun setAmount(amount: Long, decimal: Int, isAlgorand: Boolean, transactionSymbol: TransactionSymbol?) {
        setAmount(BigInteger.valueOf(amount), decimal, isAlgorand, transactionSymbol)
    }

    fun setAmount(amount: BigInteger?, decimal: Int, isAlgorand: Boolean) {
        this.isAlgorand = isAlgorand
        value = amount ?: BigInteger.ZERO
        binding.algoAmountTextView.text = value.formatAmount(decimal)
    }

    fun setAmount(amount: BigInteger?, decimal: Int, isAlgorand: Boolean, transactionSymbol: TransactionSymbol?) {
        setAmount(amount, decimal, isAlgorand)
        setColorAccordingToTransactionType(amount, transactionSymbol)
        setOperatorAccordingToTransactionType(amount, transactionSymbol)
    }

    fun setAmount(
        amount: BigInteger?,
        formattedAmount: String,
        isAlgorand: Boolean,
        transactionSymbol: TransactionSymbol?
    ) {
        this.isAlgorand = isAlgorand
        value = amount
        binding.algoAmountTextView.text = formattedAmount
        setColorAccordingToTransactionType(amount, transactionSymbol)
        setOperatorAccordingToTransactionType(amount, transactionSymbol)
    }

    companion object {
        private const val NO_COLOR_RES_ID = -2
    }
}
