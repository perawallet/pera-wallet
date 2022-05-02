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

import android.icu.text.CompactDecimalFormat
import android.icu.text.NumberFormat
import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import java.util.Locale

const val TWO_DECIMALS = 2
const val FIXED_DECIMAL_LIMIT = 999L

fun getNumberFormat(
    number: BigDecimal,
    decimals: Int,
    isDecimalFixed: Boolean = false,
    isCompact: Boolean = false
): NumberFormat {
    return if (isCompact) {
        CompactDecimalFormat.getInstance(Locale.getDefault(), CompactDecimalFormat.CompactStyle.SHORT)
    } else {
        NumberFormat.getInstance()
    }.apply {
        roundingMode = RoundingMode.FLOOR.ordinal
        maximumFractionDigits = if (
            isCompact &&
            decimals >= TWO_DECIMALS &&
            number.isGreaterThan(BigDecimal.valueOf(FIXED_DECIMAL_LIMIT))
        ) {
            TWO_DECIMALS
        } else {
            decimals
        }
        minimumFractionDigits = when {
            isDecimalFixed -> decimals
            else -> TWO_DECIMALS
        }
    }
}

private fun getAmountAsBigDecimal(amount: Long?, decimals: Int): BigDecimal {
    return when {
        amount == null -> BigDecimal.ZERO
        decimals == 0 -> BigDecimal(amount)
        else -> BigDecimal.valueOf(amount, decimals)
    }
}

fun BigDecimal.formatAmount(
    decimals: Int,
    isDecimalFixed: Boolean,
    isCompact: Boolean = false
): String {
    return getNumberFormat(this, decimals, isDecimalFixed, isCompact).format(this)
}

fun Long?.formatAmount(
    decimals: Int,
    isDecimalFixed: Boolean = false,
    isCompact: Boolean = false
): String {
    return getAmountAsBigDecimal(this, decimals).formatAmount(decimals, isDecimalFixed, isCompact)
}

fun BigInteger?.formatAmount(
    decimals: Int,
    isDecimalFixed: Boolean = false,
    isCompact: Boolean = false
): String {
    return (this ?: BigInteger.ZERO).toBigDecimal(decimals).formatAmount(decimals, isDecimalFixed, isCompact)
}

fun BigDecimal.formatAmountAsBigInteger(decimal: Int): BigInteger {
    return formatAmount(decimal, true)
        .filter { it.isDigit() }
        .toBigIntegerOrNull() ?: BigInteger.ZERO
}
