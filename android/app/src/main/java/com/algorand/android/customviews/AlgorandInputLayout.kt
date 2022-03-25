/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.customviews

import android.content.Context
import android.os.Parcelable
import android.text.InputFilter
import android.util.AttributeSet
import android.util.SparseArray
import androidx.annotation.DrawableRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.widget.addTextChangedListener
import com.algorand.android.R
import com.algorand.android.databinding.CustomInputLayoutBinding
import com.algorand.android.models.CustomInputState
import com.algorand.android.utils.addByteLimiter
import com.algorand.android.utils.extensions.setImageResAndVisibility
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class AlgorandInputLayout @JvmOverloads constructor(
    context: Context,
    private val attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomInputLayoutBinding::inflate)

    private val editText = binding.textInputEditText

    @DrawableRes
    private var endIconResource: Int = -1

    var text: String
        get() = editText.text.toString()
        set(value) {
            binding.textInputEditText.apply {
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

    private var isSingleLine by Delegates.observable(false, { _, _, newValue ->
        binding.textInputEditText.isSingleLine = newValue
    })

    private var maxCharacter by Delegates.observable(-1, { _, _, newValue ->
        if (newValue != -1) {
            with(binding.textInputEditText) {
                val newFilters = filters.toMutableList()
                newFilters.add(InputFilter.LengthFilter(newValue))
                filters = newFilters.toTypedArray()
            }
        }
    })

    init {
        loadAttrs()
        initUi()
    }

    fun setOnTextChangeListener(listener: (text: String) -> Unit) {
        binding.textInputEditText.addTextChangedListener { listener.invoke(text) }
    }

    fun setOnEndIconClickListener(listener: () -> Unit) {
        binding.iconImageView.setOnClickListener { listener.invoke() }
    }

    private fun loadAttrs() {
        context.obtainStyledAttributes(attrs, R.styleable.CustomInputLayout).use { attrs ->
            text = attrs.getString(R.styleable.CustomInputLayout_text).orEmpty()
            hint = attrs.getString(R.styleable.CustomInputLayout_hint).orEmpty()
            error = attrs.getString(R.styleable.CustomInputLayout_error).orEmpty()
            helper = attrs.getString(R.styleable.CustomInputLayout_helper).orEmpty()
            endIconResource = attrs.getResourceId(R.styleable.CustomInputLayout_endIcon, -1)
            isSingleLine = attrs.getBoolean(R.styleable.CustomInputLayout_singleLine, false)
            maxCharacter = attrs.getInteger(R.styleable.CustomInputLayout_maxCharacter, -1)
        }
    }

    private fun initUi() {
        setEndIconRes(endIconResource)
    }

    private fun setEndIconRes(@DrawableRes iconRes: Int) {
        binding.iconImageView.setImageResAndVisibility(iconRes)
    }

    fun addByteLimiter(maximumByteLimit: Int) {
        binding.textInputEditText.addByteLimiter(maximumByteLimit)
    }

    fun setAsNonFocusable() {
        binding.textInputLayout.isEnabled = false
    }

    override fun onSaveInstanceState(): Parcelable {
        return CustomInputState(super.onSaveInstanceState(), text)
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        (state as? CustomInputState)?.run {
            super.onRestoreInstanceState(superState)
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
