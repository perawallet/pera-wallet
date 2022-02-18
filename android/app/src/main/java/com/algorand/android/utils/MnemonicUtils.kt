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

import android.graphics.Typeface
import android.text.SpannableStringBuilder
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import androidx.core.text.buildSpannedString
import com.algorand.android.R

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
    rightColumnTextView.setupPassphraseColumn(
        (MAX_PASSPHRASE_ON_COLUMN + 1)..PASSPHRASE_WORD_COUNT, passphraseWords
    )
}

private fun TextView.setupPassphraseColumn(range: IntRange, passphraseWords: List<String>) {
    val positionTextColor = ContextCompat.getColor(context, R.color.secondaryTextColor)
    text = buildSpannedString {
        val textSize = context.resources.getDimensionPixelSize(R.dimen.text_size_13)
        val font = context.resources.getIdentifier("dmmono_medium", "font", context.packageName)
        val fontTypeface = ResourcesCompat.getFont(context, font)
        for (position in range) {
            val currentPassphraseWord = passphraseWords[position - 1]
            appendPosition(position, positionTextColor, textSize, fontTypeface)
            append("    $currentPassphraseWord")
            if (position != range.last) {
                append("\n")
            }
        }
    }
}

private fun SpannableStringBuilder.appendPosition(
    position: Int,
    positionTextColor: Int,
    textSize: Int,
    fontTypeface: Typeface?
) {
    val positionOfSpannable = SpannableStringBuilder().apply {
        if (position < DOUBLE_DIGIT_START_POSITION) {
            append(" $position")
        } else {
            append("$position")
        }
        setColor(positionTextColor)
        setTextSize(textSize)
        setFont(fontTypeface)
    }

    append(positionOfSpannable)
}
