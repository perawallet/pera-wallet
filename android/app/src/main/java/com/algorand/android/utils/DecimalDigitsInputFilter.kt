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

import android.text.InputFilter
import android.text.Spanned
import java.util.regex.Pattern

class DecimalDigitsInputFilter(decimalDigitCount: Int) : InputFilter {

    private val pattern: Pattern

    init {
        pattern = createFilterPattern(decimalDigitCount)
    }

    override fun filter(
        source: CharSequence,
        start: Int,
        end: Int,
        dest: Spanned,
        dstart: Int,
        dend: Int
    ): CharSequence? {
        val matchers = pattern.matcher(dest)
        val separatorIndex = getDecimalSeparatorIndex(dest)
        val isLatestInputAfterDecimalSeparator = dstart > separatorIndex
        if (!matchers.matches() && isLatestInputAfterDecimalSeparator) {
            return ""
        }
        return null
    }

    private fun getDecimalSeparatorIndex(input: Spanned): Int {
        return with(input) {
            if (contains(DOT)) indexOf(DOT) else indexOf(COMMA)
        }
    }

    private fun createFilterPattern(decimalDigitCount: Int): Pattern {
        val safeMaxDigitCount = (decimalDigitCount - 1).coerceAtLeast(0)
        return Pattern.compile("^[0-9]*(\\.[0-9]{0,$safeMaxDigitCount})?\$")
    }

    companion object {
        private const val DOT = '.'
        private const val COMMA = ','
    }
}
