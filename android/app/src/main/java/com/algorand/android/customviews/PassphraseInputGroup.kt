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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.annotation.StringRes
import androidx.core.view.children
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout

class PassphraseInputGroup @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FlexboxLayout(context, attrs) {

    private val passphraseInputArray = Array(WORD_COUNT) { index -> createPassphraseInput(index) }
    var listener: Listener? = null

    init {
        flexWrap = FlexWrap.WRAP
        flexDirection = FlexDirection.ROW
        setupPassphraseInputs()
    }

    private fun setupPassphraseInputs() {
        var leftIndex = 0
        var rightIndex = RIGHT_COLUMN_START
        repeat(WORD_COUNT) { index ->
            val currentIndex = if (index % 2 == 0) leftIndex++ else rightIndex++
            addView(passphraseInputArray[currentIndex])
        }
    }

    private fun getActualInputIndex(index: Int): Int {
        var actualIndex = 0
        var leftIndex = 0
        var rightIndex = RIGHT_COLUMN_START
        repeat(index + 1) {
            actualIndex = if (it % 2 == 0) leftIndex++ else rightIndex++
        }
        return actualIndex
    }

    private fun createPassphraseInputListener(): PassphraseInput.Listener {
        return object : PassphraseInput.Listener {
            override fun onMnemonicPasted(mnemonic: String) {
                setMnemonic(mnemonic)
            }

            override fun onInputChanged(index: Int, inputText: String) {
                listener?.onNewUpdate(index, inputText)
            }

            override fun onNextFocusRequested(currentFocusId: Int) {
                focusToNextInput(currentFocusId)
            }

            override fun onInputFocused(index: Int) {
                listener?.onInputFocus(passphraseInputArray[index])
            }

            override fun onError(errorResId: Int) {
                listener?.onError(errorResId)
            }

            override fun onDoneClick() {
                listener?.onDoneClick(isAllValidationDone())
            }
        }
    }

    private fun createPassphraseInput(index: Int): PassphraseInput {
        return PassphraseInput.create(context, index, createPassphraseInputListener()).apply {
            layoutParams = LayoutParams(
                resources.displayMetrics.widthPixels / 2,
                LayoutParams.WRAP_CONTENT
            )
        }
    }

    private fun focusToNextInput(currentFocusIndex: Int) {
        val newIndex = currentFocusIndex + 1
        if (newIndex < WORD_COUNT) {
            passphraseInputArray[newIndex].focusToInput(shouldShowKeyboard = true)
        }
    }

    private fun isAllValidationDone(): Boolean {
        return passphraseInputArray.all { it.validated }
    }

    fun setValidation(index: Int, isValidated: Boolean) {
        passphraseInputArray[index].validated = isValidated
        listener?.onMnemonicReady(isAllValidationDone())
    }

    fun getMnemonicResponse(): MnemonicResponse {
        val mnemonicStringBuilder = StringBuilder()
        passphraseInputArray.forEachIndexed { index, passphraseInput ->
            if (!passphraseInput.isValidated()) {
                val errorString = AnnotatedString(R.string.your_passphrase_is_invalid_please)
                val mnemonic = mnemonicStringBuilder.toString().trim()
                return MnemonicResponse.Error(mnemonic, errorString)
            }
            val passphraseWord = passphraseInput.getPassphraseWord().trim()
            mnemonicStringBuilder.append(if (index == 0) passphraseWord else " $passphraseWord")
        }
        return MnemonicResponse.Successful(mnemonicStringBuilder.toString().trim())
    }

    fun setMnemonic(mnemonic: String) {
        val latestFocusedInputIndex = children.indexOfFirst { it.hasFocus() }
        val keywords = mnemonic.trim().split(" ")
        val iterationCount = minOf(keywords.size, WORD_COUNT)
        repeat(iterationCount) { index ->
            passphraseInputArray[index].setWord(word = keywords[index], focusToNextOne = false)
        }
        if (latestFocusedInputIndex != -1) {
            focusTo(getActualInputIndex(latestFocusedInputIndex), shouldShowKeyboard = false)
        }
    }

    fun setSuggestedWord(index: Int, suggestedWord: String) {
        passphraseInputArray[index].setWord(suggestedWord, focusToNextOne = true)
    }

    fun focusTo(index: Int, shouldShowKeyboard: Boolean) {
        passphraseInputArray.getOrNull(index)?.focusToInput(shouldShowKeyboard = shouldShowKeyboard)
    }

    interface Listener {
        fun onInputFocus(passphraseInput: PassphraseInput)
        fun onNewUpdate(index: Int, word: String)
        fun onDoneClick(isAllValidationDone: Boolean)
        fun onMnemonicReady(isReady: Boolean)
        fun onError(@StringRes errorResId: Int)
    }

    sealed class MnemonicResponse(open val mnemonic: String) {
        data class Successful(override val mnemonic: String) : MnemonicResponse(mnemonic)
        data class Error(override val mnemonic: String, val error: AnnotatedString) : MnemonicResponse(mnemonic)
    }

    companion object {
        private const val RIGHT_COLUMN_START = 13
        const val WORD_COUNT = 25
    }
}
