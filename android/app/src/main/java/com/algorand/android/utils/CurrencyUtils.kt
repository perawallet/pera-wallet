/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.utils

import com.algorand.android.modules.currency.domain.model.Currency
import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols

const val ALGO_FULL_NAME = "Algo"
const val ALGO_SHORT_NAME = "ALGO"
const val ALGO_DECIMALS = 6
const val DEFAULT_ASSET_DECIMAL = 0
const val POSITIVE_SIGN = "+"
const val NEGATIVE_SIGN = "-"
const val NO_PRICE_SIGN = "-"
private const val FIAT_MAX_DECIMAL = 6
private const val FIAT_MIN_DECIMAL = 2

private const val ALGO_AMOUNT_FORMAT = "#,##0.00####"
private const val ALGO_DISPLAY_AMOUNT_DECIMAL = 2

fun BigDecimal.formatAsCurrency(symbol: String, isCompact: Boolean = false, isFiat: Boolean = false): String {
    val formattedString = if (isCompact) {
        val fractionalDigitCreator = getFractionalDigitCreator(isFiat)
        formatCompactNumber(this, fractionalDigitCreator)
    } else {
        formatAsCurrencyDecimals(symbol)
    }
    return StringBuilder(symbol).append(formattedString).toString()
}

private fun BigDecimal.formatAsCurrencyDecimals(symbol: String): String {
    val numberFormatter = if (symbol == Currency.ALGO.symbol) {
        getNumberFormat(ALGO_DECIMALS)
    } else {
        val decimal = getFiatFormatDecimal(this)
        getNumberFormat(decimal)
    }
    return numberFormatter.format(this)
}

fun BigInteger.toAlgoDisplayValue(): BigDecimal {
    return toBigDecimal().movePointLeft(ALGO_DECIMALS)
}

fun BigDecimal.formatAsTwoDecimals(): String {
    return getNumberFormat(TWO_DECIMALS).format(this)
}

fun Long?.formatAsAlgoString(): String {
    return DecimalFormat(ALGO_AMOUNT_FORMAT, DecimalFormatSymbols()).format(
        BigDecimal.valueOf(this ?: 0, ALGO_DECIMALS)
    )
}

fun BigInteger?.formatAsAlgoDisplayString(): String {
    return DecimalFormat(ALGO_AMOUNT_FORMAT, DecimalFormatSymbols()).format(
        this?.toBigDecimal()?.movePointLeft(ALGO_DECIMALS)?.setScale(ALGO_DISPLAY_AMOUNT_DECIMAL, RoundingMode.DOWN)
    )
}

fun BigInteger?.formatAsAlgoString(): String {
    return DecimalFormat(ALGO_AMOUNT_FORMAT, DecimalFormatSymbols()).format(
        (this ?: BigInteger.ZERO).toBigDecimal(ALGO_DECIMALS)
    )
}

fun BigDecimal?.formatAsAlgoString(): String {
    return DecimalFormat(ALGO_AMOUNT_FORMAT, DecimalFormatSymbols()).format(
        (this ?: BigDecimal.ZERO).setScale(ALGO_DECIMALS, RoundingMode.FLOOR)
    )
}

private fun getFiatFormatDecimal(number: BigDecimal): Int {
    return if (number isLesserThan BigDecimal.ONE) FIAT_MAX_DECIMAL else FIAT_MIN_DECIMAL
}
