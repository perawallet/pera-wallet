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

import android.content.Context
import android.graphics.drawable.Drawable
import android.text.InputFilter
import android.util.Base64
import android.widget.EditText
import android.widget.TextView
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentManager
import com.algorand.android.modules.currency.domain.model.Currency
import java.math.BigDecimal
import java.math.BigInteger
import java.net.URLDecoder
import java.nio.charset.StandardCharsets

@Suppress("MagicNumber")
val algoTotalSupply: BigDecimal = BigDecimal.valueOf(10_000_000_000L)

@Suppress("MagicNumber")
val minBalancePerAssetAsBigInteger: BigInteger = BigInteger.valueOf(100_000L)

const val MIN_FEE = 1000L
const val DATA_SIZE_FOR_MAX = 270
const val ROUND_THRESHOLD = 1000L
const val SHORTENED_ADDRESS_LETTER_COUNT = 6

fun DialogFragment.showWithStateCheck(fragmentManager: FragmentManager?, tag: String = "") {
    if (fragmentManager != null && fragmentManager.isStateSaved.not()) {
        show(fragmentManager, tag)
    }
}

fun String?.toShortenedAddress(): String {
    return if (!this.isNullOrBlank()) {
        "${take(SHORTENED_ADDRESS_LETTER_COUNT)}...${takeLast(SHORTENED_ADDRESS_LETTER_COUNT)}"
    } else {
        ""
    }
}

fun String?.toShortenedAddress(letterCount: Int): String {
    return if (!this.isNullOrBlank() && length >= letterCount) {
        "${take(letterCount)}...${takeLast(letterCount)}"
    } else {
        ""
    }
}

fun TextView.setDrawable(
    start: Drawable? = null,
    top: Drawable? = null,
    end: Drawable? = null,
    bottom: Drawable? = null
) = setCompoundDrawablesRelativeWithIntrinsicBounds(start, top, end, bottom)

fun EditText.addByteLimiter(maximumLimitInByte: Int) {
    doAfterTextChanged { text ->
        var textAsString = text?.toString() ?: return@doAfterTextChanged
        var deletedCharCount = 0
        while (textAsString.toByteArray(charset = Charsets.UTF_8).size > maximumLimitInByte) {
            textAsString = textAsString.dropLast(1)
            deletedCharCount++
        }
        if (deletedCharCount > 0) {
            text.delete(text.length - deletedCharCount, text.length)
        }
    }
}

fun EditText.onAction(action: Int, runAction: () -> Unit) {
    this.setOnEditorActionListener { _, actionId, _ ->
        return@setOnEditorActionListener when (actionId) {
            action -> {
                runAction.invoke()
                true
            }
            else -> false
        }
    }
}

fun String.decodeBase64IfUTF8(): String {
    val stringInByteArray = Base64.decode(this, Base64.DEFAULT)
    val decodedString = String(stringInByteArray, charset = Charsets.UTF_8)
    // malformed char converts into `\uFFFD` when decoded to UTF-8.
    return if (decodedString.contains('\uFFFD').not()) {
        decodedString
    } else {
        this
    }
}

fun Context.dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

fun EditText.addFilterNotLetters() {
    filters = arrayOf(
        InputFilter { source, start, end, _, _, _ ->
            // this ensures that only keyboard input will be filtered.
            // paste option will not be filtered.
            if (end - start == 1 && !Character.isLetter(source[start])) {
                return@InputFilter ""
            }
            null
        }
    )
}

fun String.decodeBase64(): ByteArray? {
    return try {
        Base64.decode(this, Base64.DEFAULT)
    } catch (exception: Exception) {
        // TODO Log firebase
        null
    }
}

fun String.decodeUrl(charset: String = StandardCharsets.UTF_8.name()): String? {
    return try {
        URLDecoder.decode(this, charset)
    } catch (exception: Exception) {
        recordException(exception)
        null
    }
}

fun String.formatAsAlgoAmount(transactionSign: String? = null): String {
    return transactionSign.orEmpty() + Currency.ALGO.symbol + this
}

fun String.formatAsAssetAmount(assetShortName: String?, transactionSign: String? = null): String {
    return "${transactionSign.orEmpty()}$this $assetShortName"
}
