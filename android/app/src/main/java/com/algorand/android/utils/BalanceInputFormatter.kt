package com.algorand.android.utils

import com.algorand.android.models.BalanceInput
import java.math.BigDecimal
import java.math.BigInteger
import java.text.DecimalFormat
import kotlin.properties.Delegates

class BalanceInputFormatter {

    var maxDecimalLimit = 0

    val amountInitialPlaceholder by lazy { createAmountInitialPlaceholder() }

    private var formattedText: String by Delegates.observable(EMPTY_TEXT) { _, _, newValue ->
        onFormattedTextChanged(newValue)
    }

    private var listener: Listener? = null

    private val decimalFormatter = DecimalFormat()

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
        }
    }

    fun onBackspaceClick() {
        removeLatestNumber()
    }

    fun onDotClick() {
        formattedText.run {
            formattedText = when {
                (this != amountInitialPlaceholder && contains(DOT)) || maxDecimalLimit == 0 -> return
                this == amountInitialPlaceholder -> ZERO_WITH_DOT
                else -> plus(if (isBlank()) ZERO_WITH_DOT else DOT)
            }
        }
    }

    private fun onFormattedTextChanged(formattedText: String) {
        val amountAsBigDecimal = with(formattedText) {
            takeUnless { hasDotAtTheEnd(this) } ?: dropLast(1)
        }.filter { it.isDigit() || it == DOT_CHAR }.toBigDecimalOrNull() ?: BigDecimal.ZERO

        val amountAsBigInteger = formattedText.filter { it.isDigit() }.toBigIntegerOrNull() ?: BigInteger.ZERO
        val formattedBalanceString = formatInput(formattedText)
        val balanceInput = BalanceInput(
            formattedBalance = amountAsBigInteger,
            formattedBalanceString = formattedBalanceString,
            formattedBalanceInBigDecimal = amountAsBigDecimal,
            decimal = maxDecimalLimit,
            isAmountValid = formattedBalanceString != amountInitialPlaceholder
        )

        listener?.onBalanceFormatted(balanceInput)
    }

    private fun hasDotAtTheEnd(formattedText: String): Boolean {
        return formattedText.isNotBlank() && formattedText.last().toString() == DOT
    }

    private fun shouldAddNewNumber(): Boolean {
        val remainingDecimalCount = getRemainingDecimalCount()
        return !formattedText.contains(DOT) || (formattedText.contains(DOT) && remainingDecimalCount > 0)
    }

    private fun shouldRemoveZeroPrefix(upComingNumber: Int): Boolean {
        return with(formattedText) {
            this == ZERO_CHAR.toString() || (this == amountInitialPlaceholder && upComingNumber != 0)
        }
    }

    private fun getRemainingDecimalCount(): Int {
        return if (formattedText.contains(DOT)) {
            maxDecimalLimit - formattedText.split(DOT).last().length
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
        return BigDecimal.ZERO.formatAmount(maxDecimalLimit, false)
    }

    private fun formatInput(input: String): String {
        val addedDecimalCount = if (input.contains(DOT)) formattedText.split(DOT).last().length else 0

        // BigDecimal can include only [DOT] and [DIGITS] otherwise it returns [ZERO]
        val inputAsBigDecimal = input.filter { it.isDigit() || it == DOT_CHAR }.toBigDecimalOrNull() ?: BigDecimal.ZERO
        val formatter = updateFormatter(addedDecimalCount)
        val formattedInput = formatter.format(inputAsBigDecimal)

        // Number formatter is removing trailing [DOT]
        if (input.endsWith(DOT)) {
            return formattedInput.plus(DOT)
        }
        return formattedInput
    }

    private fun updateFormatter(minimumFractionDigits: Int): DecimalFormat {
        return decimalFormatter.apply {
            maximumFractionDigits = maxDecimalLimit
            this.minimumFractionDigits = minimumFractionDigits
        }
    }

    fun interface Listener {
        fun onBalanceFormatted(balanceInput: BalanceInput)
    }

    companion object {
        private const val EMPTY_TEXT = ""
        private const val DOT = "."
        private const val DOT_CHAR = '.'
        private const val ZERO = "0"
        private const val ZERO_CHAR = '0'
        private const val DEFAULT_TEXT = "0"
        private const val ZERO_WITH_DOT = "0."
    }
}
