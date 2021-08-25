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
import android.text.Editable
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.View
import android.widget.LinearLayout
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomAmountInputBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getFullStringFormat
import com.algorand.android.utils.viewbinding.viewBinding
import java.math.BigDecimal
import java.math.BigInteger
import java.text.DecimalFormat
import java.text.NumberFormat
import kotlin.properties.Delegates

class AmountInput @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    var isTextWatcherEnabled = true

    var maximumAssetAmountInAccount by Delegates.observable<BigInteger?>(null, { _, _, newValue ->
        if (newValue != null) {
            binding.customAmountInputMaxButton.isSelected = isAmountMax()
        }
    })

    var amount by Delegates.observable<BigInteger>(BigInteger.ZERO, { _, _, _ ->
        binding.customAmountInputMaxButton.isSelected = isAmountMax()
    })
        private set

    private val binding = viewBinding(CustomAmountInputBinding::inflate)

    private var assetInformation: AssetInformation? = null
    private lateinit var fullAmountFormatter: NumberFormat

    private var decimals = 0
    private var isEditable: Boolean = false

    init {
        initView(attrs)
    }

    private fun initView(attrs: AttributeSet?) {
        orientation = VERTICAL

        context.obtainStyledAttributes(attrs, R.styleable.AmountInput).use { typedArray ->
            if (typedArray.getBoolean(R.styleable.AmountInput_editableAmount, false)) {
                isEditable = true
            } else {
                with(binding.customAmountInputTextView) {
                    isEnabled = false
                    isClickable = false
                    isFocusableInTouchMode = false
                    movementMethod = null
                    keyListener = null
                }
            }
            if (typedArray.getBoolean(R.styleable.AmountInput_isMaxEnabled, false)) {
                with(binding.customAmountInputMaxButton) {
                    setOnClickListener { onMaxClick() }
                    visibility = View.VISIBLE
                }
            }
        }
    }

    fun setupAsset(assetInformation: AssetInformation) {
        decimals = assetInformation.decimals
        fullAmountFormatter = getFullStringFormat(assetInformation.decimals)
        if (isEditable) {
            binding.customAmountInputTextView.apply {
                addTextChangedListener(currencyTextWatcher)
                setText(0.toString())
            }
        }
    }

    private fun onMaxClick() {
        if (binding.customAmountInputMaxButton.isSelected.not()) {
            maximumAssetAmountInAccount?.let { maxBalance -> setBalance(maxBalance) }
        }
    }

    fun setBalance(amount: BigInteger?) {
        val limitAwareAmount = when {
            amount == null -> {
                return
            }
            amount < BigInteger.ZERO -> {
                return
            }
            else -> {
                amount
            }
        }
        with(binding.customAmountInputTextView) {
            isTextWatcherEnabled = false
            this@AmountInput.amount = limitAwareAmount
            setText(limitAwareAmount.formatAmount(decimals, true))
            isTextWatcherEnabled = true
        }
    }

    // TODO refactor when you have time.
    private val currencyTextWatcher: TextWatcher = object : TextWatcher {
        var beforeAssetValue: BigDecimal = BigDecimal.ZERO
        var beforeTextLength = 0

        override fun afterTextChanged(changedText: Editable?) {
            if (isTextWatcherEnabled.not() || changedText == null) {
                return
            }

            binding.customAmountInputTextView.removeTextChangedListener(this)

            if (beforeTextLength < changedText.length) {
                // IF NEW NUMBER IS ENTERED
                val lastAddedNumber =
                    BigDecimal.valueOf(changedText.last().toString().toLongOrNull() ?: 0, decimals)

                val newValue = beforeAssetValue.scaleByPowerOfTen(1).add(lastAddedNumber)

                if (newValue.unscaledValue() > (BigInteger.valueOf(Long.MAX_VALUE))) {
                    // new value is bigger than long.
                    binding.customAmountInputTextView.setText(changedText.toString().dropLast(1))
                    binding.customAmountInputTextView.addTextChangedListener(this)
                    return
                }

                setNewAmount(newValue)
            } else if (beforeTextLength > changedText.length) {
                // IF DELETE IS PRESSED
                val changedTextWithoutGrouping = changedText.toString().filter { it.isDigit() }
                val newValue = if (!changedTextWithoutGrouping.isBlank()) {
                    BigDecimal(changedTextWithoutGrouping).scaleByPowerOfTen(-decimals)
                } else {
                    BigDecimal.ZERO
                }

                setNewAmount(newValue)
            }

            binding.customAmountInputTextView.addTextChangedListener(this)
        }

        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            if (s?.isNotBlank() == true && isTextWatcherEnabled) {
                beforeTextLength = s.length
                beforeAssetValue = BigDecimal(removeGroupingSeperator(s))
            }
        }

        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            // nothing to do
        }
    }

    private fun setNewAmount(value: BigDecimal) {
        amount = value.unscaledValue()
        binding.customAmountInputTextView.setText(fullAmountFormatter.format(value))
    }

    fun isAmountMax(): Boolean {
        return maximumAssetAmountInAccount == amount
    }

    private fun removeGroupingSeperator(valueText: CharSequence): String {
        return valueText.toString().replace(
            (fullAmountFormatter as DecimalFormat).decimalFormatSymbols.groupingSeparator.toString(), ""
        )
    }
}
