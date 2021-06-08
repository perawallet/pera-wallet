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

package com.algorand.android.utils

import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

const val PERCENT_FORMAT = "##0.00'%'"
const val PLUS_SIGN = "+"
const val MINUS_SIGN = "-"

fun getFormatter(
    format: String,
    includeMagnitude: Boolean = false,
    positiveSuffix: String? = null,
    negativeSuffix: String? = null
): DecimalFormat {
    return DecimalFormat(format, DecimalFormatSymbols(Locale.US)).apply {
        roundingMode = RoundingMode.DOWN
        if (positiveSuffix != null) this.positiveSuffix = positiveSuffix
        if (negativeSuffix != null) this.negativeSuffix = negativeSuffix
        if (includeMagnitude) {
            this.positivePrefix = PLUS_SIGN
            this.negativePrefix = MINUS_SIGN
        }
    }
}
