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

import android.text.SpannableStringBuilder
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.text.buildSpannedString
import androidx.core.text.color
import androidx.core.text.scale
import com.algorand.android.R

private const val SMALL_TEXT_SCALE = 0.75f
private const val MAX_PASSPHRASE_ON_COLUMN = 13
private const val PASSPHRASE_WORD_COUNT = 25
private const val DOUBLE_DIGIT_START_POSITION = 10

fun setupMnemonic(
    mnemonicString: String,
    leftColumnTextView: TextView,
    rightColumnTextView: TextView
) {
    val passphraseWords = mnemonicString.split(" ")
    leftColumnTextView.setupPassphraseColumn(1..MAX_PASSPHRASE_ON_COLUMN, passphraseWords)
    rightColumnTextView.setupPassphraseColumn((MAX_PASSPHRASE_ON_COLUMN + 1)..PASSPHRASE_WORD_COUNT, passphraseWords)
}

private fun TextView.setupPassphraseColumn(
    range: IntRange,
    passphraseWords: List<String>
) {
    val positionTextColor = ContextCompat.getColor(context, R.color.colorPrimary)
    text = buildSpannedString {
        for (position in range) {
            val currentPassphraseWord = passphraseWords[position - 1]
            appendPosition(position, positionTextColor)
            append("    $currentPassphraseWord")
            if (position != range.last) {
                append("\n")
            }
        }
    }
}

private fun SpannableStringBuilder.appendPosition(position: Int, positionTextColor: Int) {
    scale(SMALL_TEXT_SCALE) {
        color(positionTextColor) {
            if (position < DOUBLE_DIGIT_START_POSITION) {
                append(" $position")
            } else {
                append("$position")
            }
        }
    }
}
