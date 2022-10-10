package com.algorand.android.utils

import com.algorand.android.models.AmountInput
import com.algorand.android.utils.extensions.toBigDecimalWithLocale
import java.math.BigDecimal
import kotlin.properties.Delegates

class AmountInputFormatter {

    private var listener: Listener? = null

    val amountInitialPlaceholder: String
        get() = BigDecimal.ZERO.formatAmount(fractionDecimalLimit, isDecimalFixed = false)

    private val zeroWithSeparator: String
        get() = ZERO.plus(getDecimalSeparator())

    private val hasSeparator
        get() = inputText.contains(getDecimalSeparator())

    var fractionDecimalLimit: Int = DEFAULT_ASSET_DECIMAL

    private var inputText: String by Delegates.observable(EMPTY_TEXT) { _, _, newValue ->
        onFormattedTextChanged(newValue)
    }

    fun setOnInputChangeListener(listener: Listener) {
        this.listener = listener
    }

    fun setAmount(text: String) {
        inputText = text
    }

    fun onNumberClick(number: Int) {
        if (shouldRemoveZeroPrefix() || inputText.isBlank()) {
            inputText = EMPTY_TEXT
        }
        if (shouldAddNewNumber()) {
            inputText = inputText.plus(number)
            reformatCurrentText()
        }
    }

    fun onBackspaceClick() {
        removeLatestNumber()
        reformatCurrentText()
    }

    private fun reformatCurrentText() {
        if (!hasSeparator) {
            inputText = inputText.toBigDecimalWithLocale().formatAmount(
                decimals = fractionDecimalLimit,
                isDecimalFixed = false,
                minDecimals = 0
            )
        }
    }

    fun onDecimalSeparatorClick() {
        val decimalSeparator = getDecimalSeparator()
        inputText = inputText.run {
            when {
                contains(decimalSeparator) || fractionDecimalLimit == 0 -> return
                isBlank() -> zeroWithSeparator
                else -> plus(if (isBlank()) zeroWithSeparator else decimalSeparator)
            }
        }
    }

    private fun onFormattedTextChanged(formattedText: String) {
        val amountInput = AmountInput(
            formattedAmount = formattedText,
            amount = formattedText.toBigDecimalWithLocale(),
            isAmountValid = formattedText.isNotBlank()
        )
        listener?.onAmountInputFormatted(amountInput)
    }

    private fun shouldAddNewNumber(): Boolean {
        val remainingDecimalCount = getRemainingDecimalCount()
        val separator = getDecimalSeparator()
        return !inputText.contains(separator) || (inputText.contains(separator) && remainingDecimalCount > 0)
    }

    private fun shouldRemoveZeroPrefix(): Boolean {
        return with(inputText) { this == ZERO || inputText.isBlank() }
    }

    private fun getRemainingDecimalCount(): Int {
        val separator = getDecimalSeparator()
        return if (inputText.contains(separator)) {
            fractionDecimalLimit - inputText.split(separator).last().length
        } else {
            fractionDecimalLimit
        }
    }

    private fun removeLatestNumber() {
        inputText = inputText.dropLast(1)
    }

    fun interface Listener {
        fun onAmountInputFormatted(amountInput: AmountInput)
    }

    companion object {
        private const val EMPTY_TEXT = ""
        private const val ZERO = "0"
    }
}
