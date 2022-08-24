package com.algorand.android.utils

import com.algorand.android.models.BalanceInput
import com.algorand.android.utils.extensions.toBigDecimalWithLocale
import java.math.BigDecimal
import kotlin.properties.Delegates

class BalanceInputFormatter {

    var maxDecimalLimit = 0

    val amountInitialPlaceholder by lazy { createAmountInitialPlaceholder() }

    private val zeroWithSeparator by lazy { createZeroWithSeparator() }

    private var formattedText: String by Delegates.observable(EMPTY_TEXT) { _, _, newValue ->
        onFormattedTextChanged(newValue)
    }

    private var listener: Listener? = null

    fun updateAmount(text: String) {
        formattedText = text
    }

    fun setOnInputChangeListener(listener: Listener) {
        this.listener = listener
    }

    fun onNumberClick(number: Int) {
        if (shouldRemoveZeroPrefix(number)) {
            formattedText = EMPTY_TEXT
        }
        if (shouldAddNewNumber()) {
            formattedText = formattedText.plus(number)
            reformatCurrentText()
        }
    }

    fun onBackspaceClick() {
        removeLatestNumber()
        reformatCurrentText()
    }

    private fun reformatCurrentText() {
        if (!hasSeparator()) {
            formattedText = formattedText.toBigDecimalWithLocale().formatAmount(
                decimals = maxDecimalLimit,
                isDecimalFixed = false,
                minDecimals = 0
            )
        }
    }

    private fun hasSeparator(): Boolean {
        return formattedText.contains(getDecimalSeparator())
    }

    fun onDecimalSeparatorClick() {
        formattedText.run {
            formattedText = when {
                (this != amountInitialPlaceholder && contains(getDecimalSeparator())) || maxDecimalLimit == 0 -> return
                this == amountInitialPlaceholder -> zeroWithSeparator
                else -> plus(if (isBlank()) zeroWithSeparator else getDecimalSeparator())
            }
        }
    }

    private fun createZeroWithSeparator(): String {
        return ZERO.plus(getDecimalSeparator())
    }

    private fun onFormattedTextChanged(formattedText: String) {
        val balanceInput = BalanceInput(
            formattedBalanceString = formattedText,
            formattedBalanceInBigDecimal = formattedText.toBigDecimalWithLocale(),
            decimal = maxDecimalLimit,
            isAmountValid = formattedText != amountInitialPlaceholder || formattedText.isNotEmpty()
        )
        listener?.onBalanceFormatted(balanceInput)
    }

    private fun shouldAddNewNumber(): Boolean {
        val remainingDecimalCount = getRemainingDecimalCount()
        val separator = getDecimalSeparator()
        return !formattedText.contains(separator) || (formattedText.contains(separator) && remainingDecimalCount > 0)
    }

    private fun shouldRemoveZeroPrefix(upComingNumber: Int): Boolean {
        return with(formattedText) {
            this == ZERO || (this == amountInitialPlaceholder && formattedText.isBlank())
        }
    }

    private fun getRemainingDecimalCount(): Int {
        val separator = getDecimalSeparator()
        return if (formattedText.contains(separator)) {
            maxDecimalLimit - formattedText.split(separator).last().length
        } else {
            maxDecimalLimit
        }
    }

    private fun removeLatestNumber() {
        formattedText = with(formattedText) {
            when {
                length <= 1 -> ZERO
                else -> dropLast(1)
            }
        }
    }

    private fun createAmountInitialPlaceholder(): String {
        return BigDecimal.ZERO.formatAmount(maxDecimalLimit, isDecimalFixed = false)
    }

    fun interface Listener {
        fun onBalanceFormatted(balanceInput: BalanceInput)
    }

    companion object {
        private const val EMPTY_TEXT = ""
        private const val ZERO = "0"
    }
}
