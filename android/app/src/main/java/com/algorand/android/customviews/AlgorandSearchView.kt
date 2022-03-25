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
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat.getColor
import androidx.core.content.ContextCompat.getDrawable
import androidx.core.content.res.use
import androidx.core.view.isVisible
import androidx.core.widget.doOnTextChanged
import com.algorand.android.R
import com.algorand.android.databinding.CustomSearchBarBinding
import com.algorand.android.utils.extensions.setIconAndVisibility
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.showKeyboard
import com.algorand.android.utils.viewbinding.viewBinding

class AlgorandSearchView @JvmOverloads constructor(
    context: Context,
    private val attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomSearchBarBinding::inflate)

    private var onTextChange: ((String) -> Unit)? = null

    var text: String
        set(value) {
            binding.searchEditText.apply {
                setText(value)
                setSelection(length())
            }
        }
        get() = binding.searchEditText.text.toString()

    init {
        loadAttrs()
        initRootView()
        initListeners()
    }

    private fun initRootView() {
        setBackgroundResource(R.drawable.bg_search_bar)
    }

    private fun initListeners() {
        with(binding) {
            searchEditText.doOnTextChanged(::searchEditTextChange)
            deleteTextButton.setOnClickListener { setOnDeleteButtonClick() }
        }
    }

    private fun loadAttrs() {
        context?.obtainStyledAttributes(attrs, R.styleable.AlgorandSearchBarView)?.use { attrs ->
            attrs.getResourceId(R.styleable.AlgorandSearchBarView_startIconTintColor, -1).let { color ->
                val drawable = getDrawable(context, R.drawable.ic_search)?.apply {
                    setTint(getColor(context, color))
                }
                binding.searchEditText.setDrawable(start = drawable)
            }
            attrs.getResourceId(R.styleable.AlgorandSearchBarView_endIconTintColor, -1).let { color ->
                binding.deleteTextButton.setIconTintResource(color)
            }
            attrs.getResourceId(R.styleable.AlgorandSearchBarView_android_hint, -1).let { hint ->
                binding.searchEditText.hint = resources.getString(hint)
            }
            val customButtonIconTintColor = attrs.getResourceId(
                R.styleable.AlgorandSearchBarView_customButtonIconColor,
                -1
            )
            attrs.getResourceId(R.styleable.AlgorandSearchBarView_customButtonIconRes, -1).let { icon ->
                binding.customIconButton.setIconAndVisibility(icon, customButtonIconTintColor)
            }
        }
    }

    private fun searchEditTextChange(text: CharSequence?, start: Int, before: Int, count: Int) {
        with(binding) {
            onTextChange?.invoke(text.toString())
            deleteTextButton.isVisible = text.toString().isNotEmpty()
            customIconButton.isVisible = text.toString().isEmpty()
        }
    }

    fun setOnTextChanged(onTextChange: (String) -> Unit) {
        this.onTextChange = onTextChange
    }

    fun setOnCustomButtonClick(onCustomButtonClick: () -> Unit) {
        binding.customIconButton.setOnClickListener { onCustomButtonClick() }
    }

    fun setOnClickListener(onClick: () -> Unit) {
        binding.searchEditText.setOnClickListener { onClick() }
    }

    fun setAsNonFocusable() {
        binding.searchEditText.isFocusable = false
    }

    fun setFocusAndOpenKeyboard() {
        with(binding.searchEditText) {
            post {
                requestFocus()
                showKeyboard()
            }
        }
    }

    private fun setOnDeleteButtonClick() {
        binding.searchEditText.setText("")
    }
}
