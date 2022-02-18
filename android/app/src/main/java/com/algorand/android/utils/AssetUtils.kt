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

import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import java.text.NumberFormat
import java.util.Locale

private const val MIN_DECIMAL_SHOW_FORMAT = 2
const val DOLLAR_DECIMALS = 2
const val ALGO_REWARD_DECIMALS = 2

private fun getBaseNumberFormat(): NumberFormat {
    return NumberFormat.getInstance(Locale.US).apply {
        isGroupingUsed = true
    }
}

fun getStringFormat(decimals: Int): NumberFormat {
    return getBaseNumberFormat().apply {
        maximumFractionDigits = decimals
        minimumFractionDigits = if (decimals >= MIN_DECIMAL_SHOW_FORMAT) MIN_DECIMAL_SHOW_FORMAT else 0
    }
}

fun getFullStringFormat(decimals: Int): NumberFormat {
    return getBaseNumberFormat().apply {
        maximumFractionDigits = decimals
        minimumFractionDigits = decimals
    }
}

private fun getAmountAsBigDecimal(amount: Long?, decimals: Int): BigDecimal {
    return when {
        amount == null -> BigDecimal.ZERO
        decimals == 0 -> BigDecimal(amount)
        else -> BigDecimal.valueOf(amount, decimals)
    }
}

fun BigDecimal.formatAmount(decimals: Int, fullFormatNeeded: Boolean): String {
    val formatTemplate = if (fullFormatNeeded) getFullStringFormat(decimals) else getStringFormat(decimals)
    return formatTemplate.format(this)
}

fun BigDecimal.formatAsDollar(): String {
    return getFullStringFormat(DOLLAR_DECIMALS).apply {
        roundingMode = RoundingMode.FLOOR
    }.format(this)
}

fun Long?.formatAmount(decimals: Int, fullFormatNeeded: Boolean = false): String {
    return getAmountAsBigDecimal(this, decimals).formatAmount(decimals, fullFormatNeeded)
}

fun BigInteger?.formatAmount(decimals: Int, fullFormatNeeded: Boolean = false): String {
    return (this ?: BigInteger.ZERO).toBigDecimal(decimals).formatAmount(decimals, fullFormatNeeded)
}

fun BigDecimal.toFullAmountInBigInteger(decimal: Int): BigInteger {
    return formatAmount(decimal, true)
        .filter { it.isDigit() }
        .toBigIntegerOrNull() ?: BigInteger.ZERO
}
