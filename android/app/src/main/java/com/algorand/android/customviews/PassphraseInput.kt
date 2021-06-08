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
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo.IME_ACTION_DONE
import android.view.inputmethod.EditorInfo.IME_ACTION_NEXT
import android.widget.TextView
import androidx.annotation.StringRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.widget.doOnTextChanged
import com.algorand.android.R
import com.algorand.android.customviews.PassphraseInputGroup.Companion.WORD_COUNT
import com.algorand.android.databinding.CustomPassphraseInputBinding
import com.algorand.android.utils.addFilterNotLetters
import com.algorand.android.utils.showKeyboard
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.firebase.crashlytics.FirebaseCrashlytics
import kotlin.properties.Delegates

class PassphraseInput @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomPassphraseInputBinding::inflate)

    private var listener: Listener? = null
    private var index = -1
    var validated by Delegates.observable(
        initialValue = false,
        onChange = { _, oldValue, newValue -> if (oldValue != newValue) onValidationChanged(newValue) }
    )

    init {
        setBackgroundResource(R.drawable.bg_shadow_inset_no_background)
        binding.passphraseInputEditText.setOnFocusChangeListener(::onFocusChanged)
        setupPasteListener()
        setupInputChangeListener()
        binding.passphraseInputEditText.addFilterNotLetters()
    }

    fun setup(index: Int, listener: Listener) {
        updateIndex(index)
        setupEditorAction()
        this.listener = listener
    }

    private fun updateIndex(index: Int) {
        this.index = index
        binding.passphraseIndexTextView.text = (index + 1).toString()
    }

    private fun setupPasteListener() {
        binding.passphraseInputEditText.doOnPaste {
            val pastedText = binding.passphraseInputEditText.text.toString()
            val splittedText = pastedText.trim().split(" ")
            if (splittedText.size == WORD_COUNT) {
                listener?.onMnemonicPasted(pastedText.trim())
            } else if (splittedText.size > 1) {
                listener?.onError(R.string.the_last_copied_text)
                binding.passphraseInputEditText.setText("")
            }
        }
    }

    private fun setupInputChangeListener() {
        binding.passphraseInputEditText.doOnTextChanged { inputText, _, _, count ->
            if (index != -1) {
                checkIfInputFromKeyboardSuggestion(inputText, count)
            }
            handleIndexTextColor()
        }
    }

    private fun checkIfInputFromKeyboardSuggestion(inputText: CharSequence?, count: Int) {
        if (count > 2 && inputText?.contains(" ") == true) {
            binding.passphraseInputEditText.listener?.onPaste()
        } else {
            validated = false
            listener?.onInputChanged(index, inputText.toString())
        }
    }

    private fun setupEditorAction() {
        setImeOptions()
        binding.passphraseInputEditText.setOnEditorActionListener(::onEditorActionClick)
    }

    private fun isLastItem(): Boolean {
        return index + 1 == WORD_COUNT
    }

    private fun setImeOptions() {
        binding.passphraseInputEditText.imeOptions = if (isLastItem()) IME_ACTION_DONE else IME_ACTION_NEXT
    }

    private fun onEditorActionClick(textView: TextView, actionId: Int, keyEvent: KeyEvent?): Boolean {
        if (index == -1) {
            val errorMessage = "index is -1 for ${PassphraseInput::class.java.name}"
            FirebaseCrashlytics.getInstance().recordException(Exception(errorMessage))
            return true
        }
        if (validated.not()) {
            return true
        }
        if (isLastItem()) {
            listener?.onDoneClick()
        } else {
            listener?.onNextFocusRequested(index)
        }
        return true
    }

    private fun onFocusChanged(view: View, isFocused: Boolean) {
        if (isFocused) {
            listener?.onInputFocused(index)
            listener?.onInputChanged(index, binding.passphraseInputEditText.text.toString())
            setBackgroundResource(R.drawable.bg_small_shadow)
        } else {
            setBackgroundResource(R.drawable.bg_shadow_inset_no_background)
        }
    }

    private fun onValidationChanged(isValidated: Boolean) {
        val newTextColor = if (isValidated) R.color.primaryTextColor else R.color.red_E9
        binding.passphraseInputEditText.setTextColor(ContextCompat.getColor(context, newTextColor))
        handleIndexTextColor()
    }

    private fun handleIndexTextColor() {
        val isEditableAreaClear = binding.passphraseInputEditText.text.isNullOrEmpty()
        val indexTextColor = if (validated || isEditableAreaClear) R.color.secondaryTextColor else R.color.red_E9
        binding.passphraseIndexTextView.setTextColor(ContextCompat.getColor(context, indexTextColor))
    }

    fun getPassphraseWord(): String {
        return binding.passphraseInputEditText.text.toString()
    }

    fun isValidated(): Boolean {
        return validated
    }

    fun focusToInput(shouldShowKeyboard: Boolean) {
        binding.passphraseInputEditText.post {
            if (binding.passphraseInputEditText.requestFocus()) {
                listener?.onInputChanged(index, binding.passphraseInputEditText.text.toString())
            }
            if (shouldShowKeyboard) binding.passphraseInputEditText.showKeyboard()
        }
    }

    fun setWord(word: String, focusToNextOne: Boolean) {
        binding.passphraseInputEditText.apply {
            setText(word)
            setSelection(word.length)
        }
        if (focusToNextOne) {
            listener?.onNextFocusRequested(index)
        }
    }

    companion object {
        fun create(context: Context, index: Int, listener: Listener): PassphraseInput {
            return PassphraseInput(context).apply {
                id = ViewCompat.generateViewId()
                setup(index, listener)
            }
        }
    }

    interface Listener {
        fun onMnemonicPasted(mnemonic: String)
        fun onInputChanged(index: Int, inputText: String)
        fun onNextFocusRequested(currentFocusId: Int)
        fun onInputFocused(index: Int)
        fun onError(@StringRes errorResId: Int)
        fun onDoneClick()
    }
}
