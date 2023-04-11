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

package com.algorand.android.customviews.passphraseinput

import android.content.Context
import android.text.Editable
import android.util.AttributeSet
import android.view.View.OnFocusChangeListener
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.widget.addTextChangedListener
import com.algorand.android.R
import com.algorand.android.customviews.PasteAwareEditText
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputConfiguration
import com.algorand.android.databinding.CustomPassphraseInputBinding
import com.algorand.android.utils.addFilterNotLetters
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class PassphraseInput @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomPassphraseInputBinding::inflate)

    private var listener: Listener? = null

    var index: Int? = null
        private set

    var order: Int? = null
        private set

    private var inputText: String? by Delegates.observable(null) { _, oldValue, newValue ->
        if (oldValue != newValue && newValue != null) {
            with(binding.passphraseInputEditText) {
                setText(newValue)
                setSelection(newValue.length)
            }
        }
    }

    private val pasteAwareEditTextListener = PasteAwareEditText.Listener { clipboardText ->
        listener?.onClipboardTextPasted(clipboardText)
    }

    private val inputEditTextActionListener = TextView.OnEditorActionListener { _, actionId, _ ->
        useSafeOrder { listener?.onImeActionClicked(itemOrder = this, actionId = actionId) }
        return@OnEditorActionListener true
    }

    private val inputEditTextFocusChangeListener = OnFocusChangeListener { _, hasFocus ->
        if (hasFocus) {
            useSafeOrder { listener?.onViewFocused(itemOrder = this, yCoordinate = bottom - measuredHeight) }
        }
    }

    init {
        id = ViewCompat.generateViewId()
        initRootView()
        isFocusableInTouchMode = true
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun initPassphraseInput(imeOption: Int) {
        binding.passphraseInputEditText.apply {
            imeOptions = imeOption
            setOnEditorActionListener(inputEditTextActionListener)
            addFilterNotLetters()
            addTextChangedListener { onTextChanged(it) }
            onFocusChangeListener = inputEditTextFocusChangeListener
            setListener(pasteAwareEditTextListener)
        }
    }

    fun initPassphraseIndexView(index: Int, itemOrder: Int) {
        this@PassphraseInput.index = index
        this@PassphraseInput.order = itemOrder
        binding.passphraseIndexTextView.text = itemOrder.inc().toString()
    }

    fun setConfiguration(passphraseInputConfiguration: PassphraseInputConfiguration) {
        with(passphraseInputConfiguration) {
            with(binding) {
                passphraseInputEditText.apply {
                    setTextColor(ContextCompat.getColor(context, textColor))
                    inputText = input
                }
                passphraseIndexTextView.setTextColor(ContextCompat.getColor(context, indexTextColor))
                passphraseInputLine.apply {
                    layoutParams.height = resources.getDimensionPixelOffset(underLineHeight)
                    setBackgroundColor(ContextCompat.getColor(context, underLineColor))
                }
            }
        }
    }

    fun focusToInput() {
        binding.passphraseInputEditText.requestFocus()
    }

    private fun onTextChanged(editable: Editable?) {
        when {
            editable == null -> return
            editable.count() > 2 && editable.contains(" ") -> listener?.onClipboardTextPasted(editable.toString())
            else -> {
                inputText = editable.toString()
                useSafeOrder { listener?.onFocusedWordChanged(this, editable.toString()) }
            }
        }
    }

    private fun initRootView() {
        setBackgroundResource(R.drawable.bg_shadow_inset_no_background)
    }

    private fun useSafeOrder(block: Int.() -> Unit) {
        order?.let(block)
    }

    interface Listener {
        fun onFocusedWordChanged(itemOrder: Int, inputText: String)
        fun onClipboardTextPasted(clipboardText: String)
        fun onViewFocused(itemOrder: Int, yCoordinate: Int)
        fun onImeActionClicked(itemOrder: Int, actionId: Int)
    }
}
