/*
 * Copyright 2022 Pera Wallet, LDA
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

package com.algorand.android.utils.extensions

import com.algorand.android.utils.recordException
import java.math.BigDecimal
import java.text.DecimalFormat
import java.text.NumberFormat
import java.util.Locale

/**
 * @throws IndexOutOfBoundsException
 */
fun String.formatAsAvatarTextOrThrow(maxLength: Int): String {
    val splitItem = trim().split(" ", "-").filter { it.isNotBlank() }
    return if (splitItem.size == 1) {
        splitItem.firstOrNull()
    } else {
        splitItem.joinToString("") { s -> s.substring(0, 1) }
    }?.take(maxLength)?.uppercase(Locale.ENGLISH).orEmpty()
}

fun String.replaceAt(start: Int, element: String): String {
    if (start > length || start < 0) return this
    val end = if (start + 1 > length) start else start + 1
    return replaceRange(start, end, element)
}

fun String.appendAt(start: Int, element: String): String {
    if (start > length || start < 0) return this
    return replaceRange(start, start, element)
}

fun String.removeAt(start: Int): String {
    if (start > length || start < 0) return this
    val end = if (start + 1 > length) start else start + 1
    return removeRange(start, end)
}

fun String.wrapWithBrackets(): String {
    return StringBuilder().apply {
        append("(")
        append(this@wrapWithBrackets)
        append(")")
    }.toString()
}

fun String.toBigDecimalWithLocale(): BigDecimal {
    if (this.isBlank()) {
        return BigDecimal.ZERO
    }
    val numberFormat: NumberFormat = NumberFormat.getNumberInstance()
    val decimalFormat: DecimalFormat? = numberFormat as? DecimalFormat
    decimalFormat?.isParseBigDecimal = true
    return try {
        decimalFormat?.parse(this) as? BigDecimal ?: BigDecimal.ZERO
    } catch (exception: Exception) {
        recordException(exception)
        BigDecimal.ZERO
    }
}

fun String.capitalize(): String {
    return lowercase(Locale.getDefault())
        .replaceFirstChar {
            if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
        }
}

fun String.addHashtagToStart(): String {
    return "#$this"
}
