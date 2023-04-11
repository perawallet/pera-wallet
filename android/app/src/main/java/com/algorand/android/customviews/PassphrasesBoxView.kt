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

package com.algorand.android.customviews

import android.content.Context
import android.graphics.Typeface
import android.text.SpannedString
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import androidx.core.text.buildSpannedString
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomPassphrasesBoxViewBinding
import com.algorand.android.utils.FontIdentifier
import com.algorand.android.utils.MNEMONIC_DELIMITER_REGEX
import com.algorand.android.utils.PassphraseViewUtils
import com.algorand.android.utils.setColor
import com.algorand.android.utils.setFont
import com.algorand.android.utils.setTextSize
import com.algorand.android.utils.viewbinding.viewBinding

class PassphrasesBoxView @JvmOverloads constructor(
    context: Context,
    attributeSet: AttributeSet? = null
) : LinearLayout(context, attributeSet) {

    private val binding = viewBinding(CustomPassphrasesBoxViewBinding::inflate)

    init {
        initRootView()
    }

    private val passphraseTextSize = resources.getDimensionPixelSize(R.dimen.text_size_13)
    private val passphraseFont = resources.getIdentifier(
        FontIdentifier.DM_MONO_REGULAR_FONT_IDENTIFIER,
        FontIdentifier.FONT_ATTRIBUTE_DEF_TYPE,
        context.packageName
    )
    private val passphraseFontFace = ResourcesCompat.getFont(context, passphraseFont)

    fun setPassphrases(passphrases: String) {
        val passphrasesAsList = splitPassphrases(passphrases)
        setPassphrases(passphrasesAsList)
    }

    fun setPassphrases(passphrases: List<String>) {
        val itemCount = passphrases.count()
        val itemCountPerColumn = PassphraseViewUtils.calculateMiddleIndexOfPassphrases(passphrases.size)

        val leftColumnItems = passphrases.subList(0, itemCountPerColumn)
        initializeGivenColumn(
            startIndex = 1,
            passphrases = leftColumnItems,
            textView = binding.passphraseLeftColumnTextView
        )

        val rightColumnItems = passphrases.subList(itemCountPerColumn, itemCount)
        initializeGivenColumn(
            startIndex = itemCountPerColumn.inc(),
            passphrases = rightColumnItems,
            textView = binding.passphraseRightColumnTextView
        )
    }

    private fun initializeGivenColumn(startIndex: Int, passphrases: List<String>, textView: TextView) {
        val positionTextColor = ContextCompat.getColor(context, R.color.text_gray)
        textView.text = buildSpannedString {
            passphrases.forEachIndexed { index, element ->
                val positionSpannable = appendPosition(
                    position = index + startIndex,
                    textColor = positionTextColor,
                    textSize = passphraseTextSize,
                    typeFace = passphraseFontFace
                )
                append(positionSpannable)
                append("$SPACES_BETWEEN_PASSPHRASES_COLUMN$element")
                if (index != passphrases.size - 1) {
                    appendLine()
                }
            }
        }
    }

    private fun appendPosition(position: Int, textColor: Int, textSize: Int, typeFace: Typeface?): SpannedString {
        return buildSpannedString {
            val positionSpannable = if (position < DOUBLE_DIGIT_START_POSITION) " $position" else "$position"
            append(positionSpannable)
            setColor(textColor)
            setTextSize(textSize)
            setFont(typeFace)
        }
    }

    private fun splitPassphrases(passphrases: String): List<String> {
        return passphrases.trim().split(Regex(MNEMONIC_DELIMITER_REGEX))
    }

    private fun initRootView() {
        setBackgroundResource(R.drawable.bg_passphrase_background)
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_xlarge))
    }

    companion object {
        private const val SPACES_BETWEEN_PASSPHRASES_COLUMN = "    "
        private const val DOUBLE_DIGIT_START_POSITION = 10
    }
}
