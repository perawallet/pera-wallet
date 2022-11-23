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

import android.icu.text.NumberFormat
import com.mitsinsar.peracompactdecimalformat.utils.fractionaldigit.AssetFractionalDigit
import com.mitsinsar.peracompactdecimalformat.utils.fractionaldigit.CollectibleFractionalDigit
import com.mitsinsar.peracompactdecimalformat.utils.fractionaldigit.FiatFractionalDigit
import com.mitsinsar.peracompactdecimalformat.utils.fractionaldigit.FractionalDigit
import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols

const val TWO_DECIMALS = 2

fun getNumberFormat(
    decimals: Int,
    isDecimalFixed: Boolean = false,
    minDecimals: Int? = null
): NumberFormat {
    return NumberFormat.getInstance().apply {
        roundingMode = RoundingMode.DOWN.ordinal
        maximumFractionDigits = decimals
        minimumFractionDigits = when {
            minDecimals != null -> minDecimals
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
    isCompact: Boolean = false,
    minDecimals: Int? = null,
    isFiat: Boolean = false
): String {
    return if (isCompact) {
        val fractionalDigitCreator = getFractionalDigitCreator(isFiat)
        formatCompactNumber(this, fractionalDigitCreator)
    } else {
        getNumberFormat(decimals, isDecimalFixed, minDecimals).format(this)
    }
}

fun Long?.formatAmount(
    decimals: Int,
    isDecimalFixed: Boolean = false,
    isCompact: Boolean = false,
    isFiat: Boolean = false
): String {
    return getAmountAsBigDecimal(this, decimals).formatAmount(decimals, isDecimalFixed, isCompact, isFiat = isFiat)
}

fun BigInteger?.formatAmount(
    decimals: Int,
    isDecimalFixed: Boolean = false,
    isCompact: Boolean = false,
    isFiat: Boolean = false
): String {
    return (this ?: BigInteger.ZERO).toBigDecimal(decimals)
        .formatAmount(decimals, isDecimalFixed, isCompact, isFiat = isFiat)
}

fun BigInteger?.formatAmountByCollectibleFractionalDigit(
    decimals: Int,
    isDecimalFixed: Boolean = false,
    isCompact: Boolean = false
): String {
    return (this ?: BigInteger.ZERO).toBigDecimal(decimals).formatAmount(
        decimals = decimals,
        isDecimalFixed = isDecimalFixed,
        isCompact = isCompact,
        fractionalDigit = CollectibleFractionalDigit
    )
}

fun BigDecimal.formatAmount(
    decimals: Int,
    isDecimalFixed: Boolean,
    isCompact: Boolean = false,
    minDecimals: Int? = null,
    fractionalDigit: FractionalDigit.FractionalDigitCreator
): String {
    return if (isCompact) {
        formatCompactNumber(this, fractionalDigit)
    } else {
        getNumberFormat(decimals, isDecimalFixed, minDecimals).format(this)
    }
}

fun BigDecimal.formatAmountAsBigInteger(decimal: Int, isFiat: Boolean = false): BigInteger {
    return formatAmount(decimal, true, isFiat = isFiat)
        .filter { it.isDigit() }
        .toBigIntegerOrNull() ?: BigInteger.ZERO
}

fun String.appendAssetName(assetName: AssetName): String {
    return if (assetName.getName() != null) "$this ${assetName.getName()}" else this
}

fun getDecimalSeparator(): String {
    val numberFormat: java.text.NumberFormat = java.text.NumberFormat.getInstance()
    val separator: DecimalFormatSymbols? = (numberFormat as? DecimalFormat)?.decimalFormatSymbols
    return separator?.decimalSeparator.toString()
}

// TODO Find a better solution for this
fun getFractionalDigitCreator(isFiat: Boolean): FractionalDigit.FractionalDigitCreator {
    return if (isFiat) FiatFractionalDigit else AssetFractionalDigit
}
