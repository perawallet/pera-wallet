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
import android.os.Parcelable
import android.text.InputFilter
import android.text.InputType
import android.util.AttributeSet
import android.util.SparseArray
import android.view.inputmethod.EditorInfo
import androidx.annotation.DrawableRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.updatePadding
import androidx.core.widget.addTextChangedListener
import com.algorand.android.R
import com.algorand.android.databinding.CustomInputLayoutBinding
import com.algorand.android.models.CustomInputSavedState
import com.algorand.android.utils.addByteLimiter
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.onAction
import com.algorand.android.utils.requestFocusAndShowKeyboard
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class AlgorandInputLayout @JvmOverloads constructor(
    context: Context,
    private val attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomInputLayoutBinding::inflate)

    private val editText get() = binding.textInputEditText

    var text: String
        get() = editText.text.toString()
        set(value) {
            editText.apply {
                setText(value)
                setSelection(length())
            }
        }

    var hint: String?
        get() = binding.textInputLayout.hint.toString()
        set(value) {
            binding.textInputLayout.hint = value
        }

    var error: String?
        get() = binding.errorTextView.text.toString()
        set(value) {
            binding.errorTextView.setTextAndVisibility(value)
        }

    var helper: String?
        get() = binding.helperTextView.text.toString()
        set(value) {
            binding.helperTextView.setTextAndVisibility(value)
        }

    private var isSingleLine by Delegates.observable(false) { _, _, newValue ->
        editText.isSingleLine = newValue
    }

    private var maxCharacter by Delegates.observable(-1) { _, _, newValue ->
        if (newValue != -1) {
            with(editText) {
                val newFilters = filters.toMutableList()
                newFilters.add(InputFilter.LengthFilter(newValue))
                filters = newFilters.toTypedArray()
            }
        }
    }

    private var inputType by Delegates.observable(InputType.TYPE_CLASS_TEXT) { _, oldValue, newValue ->
        if (newValue != oldValue) {
            editText.inputType = newValue
        }
    }

    private var imeOptions by Delegates.observable(EditorInfo.IME_ACTION_DONE) { _, oldValue, newValue ->
        if (newValue != oldValue) {
            editText.imeOptions = newValue
        }
    }

    private var isClearButtonEnabled by Delegates.observable(false) { _, oldValue, newValue ->
        if (oldValue != newValue && newValue) {
            binding.iconContainerView.enableClearButton(onIconClick = ::clearInput)
        }
    }

    init {
        loadAttrs()
    }

    private fun loadAttrs() {
        context.obtainStyledAttributes(attrs, R.styleable.CustomInputLayout).use { attrs ->
            text = attrs.getString(R.styleable.CustomInputLayout_text).orEmpty()
            hint = attrs.getString(R.styleable.CustomInputLayout_hint).orEmpty()
            error = attrs.getString(R.styleable.CustomInputLayout_error).orEmpty()
            helper = attrs.getString(R.styleable.CustomInputLayout_helper).orEmpty()
            isSingleLine = attrs.getBoolean(R.styleable.CustomInputLayout_singleLine, false)
            maxCharacter = attrs.getInteger(R.styleable.CustomInputLayout_maxCharacter, -1)
            inputType = attrs.getInt(R.styleable.CustomInputLayout_android_inputType, InputType.TYPE_CLASS_TEXT)
            imeOptions = attrs.getInt(R.styleable.CustomInputLayout_android_imeOptions, EditorInfo.IME_ACTION_DONE)
            isClearButtonEnabled = attrs.getBoolean(R.styleable.CustomInputLayout_showClearButton, false)
        }
    }

    fun setOnTextChangeListener(listener: (text: String) -> Unit) {
        editText.addTextChangedListener {
            listener.invoke(it.toString())
            if (isClearButtonEnabled) {
                binding.iconContainerView.changeClearButtonVisibility(it.toString().isNotBlank())
            }
        }
    }

    fun setImeOptionsNext(callback: () -> Unit) {
        with(editText) {
            imeOptions = EditorInfo.IME_ACTION_NEXT
            onAction(EditorInfo.IME_ACTION_NEXT, callback)
        }
    }

    fun setImeOptionsDone(callback: () -> Unit) {
        with(editText) {
            imeOptions = EditorInfo.IME_ACTION_DONE
            onAction(EditorInfo.IME_ACTION_DONE, callback)
        }
    }

    fun setInputTypeText() {
        editText.inputType = InputType.TYPE_CLASS_TEXT
    }

    fun addByteLimiter(maximumByteLimit: Int) {
        binding.textInputEditText.addByteLimiter(maximumByteLimit)
    }

    fun setAsNonFocusable() {
        binding.textInputLayout.isEnabled = false
    }

    fun addTrailingIcon(@DrawableRes drawableRes: Int, onIconClick: () -> Unit) {
        with(binding) {
            iconContainerView.addIconView(drawableRes, onIconClick)
            iconContainerView.post {
                textInputEditText.updatePadding(right = iconContainerView.width)
            }
        }
    }

    fun setInputFilter(inputFilter: InputFilter) {
        editText.filters += inputFilter
    }

    fun setOnEditorEnterClickListener(onClick: () -> Unit) {
        editText.setOnEditorActionListener { _, actionId, event ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                onClick()
                return@setOnEditorActionListener true
            }
            false
        }
    }

    fun requestFocusAndShowKeyboard() {
        editText.requestFocusAndShowKeyboard()
    }

    private fun clearInput() {
        text = ""
    }

    override fun onSaveInstanceState(): Parcelable {
        return CustomInputSavedState(super.onSaveInstanceState(), text)
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        super.onRestoreInstanceState(state)
        (state as? CustomInputSavedState)?.run {
            this@AlgorandInputLayout.text = text
        }
    }

    override fun dispatchSaveInstanceState(container: SparseArray<Parcelable>?) {
        super.dispatchFreezeSelfOnly(container)
    }

    override fun dispatchRestoreInstanceState(container: SparseArray<Parcelable>?) {
        super.dispatchThawSelfOnly(container)
    }
}
