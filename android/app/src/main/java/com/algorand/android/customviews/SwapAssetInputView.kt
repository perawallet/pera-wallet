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
import android.graphics.drawable.Drawable
import android.os.Parcelable
import android.text.Editable
import android.text.InputFilter
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.View
import androidx.appcompat.content.res.AppCompatResources
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.isVisible
import androidx.core.widget.addTextChangedListener
import com.algorand.android.R
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.databinding.CustomSwapAssetInputBinding
import com.algorand.android.models.CustomInputSavedState
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.requestFocusAndShowKeyboard
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding

class SwapAssetInputView(context: Context, attrs: AttributeSet? = null) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomSwapAssetInputBinding::inflate)

    init {
        initAttributes(attrs)
        initViewIdAndConstraints()
        initRootClickListener()
    }

    private var textChangeListener: TextChangeListener? = null

    private var latestAmountInputValue: String = ""

    private var textChangeWatcher: TextWatcher? = null

    private val afterTextChangedListener: (Editable?) -> Unit = { editable ->
        val newValue = editable.toString()
        if (newValue != latestAmountInputValue) {
            latestAmountInputValue = newValue
            textChangeListener?.onTextChanged(newValue)
        }
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context?.obtainStyledAttributes(attrs, R.styleable.SwapAssetInputView)?.use {
            with(binding) {
                titleTextView.apply {
                    val title = it.getString(R.styleable.SwapAssetInputView_title)
                    text = title
                    isVisible = !title.isNullOrBlank()
                }
                balanceTextView.isVisible = it.getBoolean(R.styleable.SwapAssetInputView_isBalanceVisible, true)
                it.getBoolean(R.styleable.SwapAssetInputView_isAssetChipClickable, true).let { isChipClickable ->
                    assetChipArrowImageView.isVisible = isChipClickable
                }
                it.getBoolean(R.styleable.SwapAssetInputView_isInputEnabled, true).let { isInputEnabled ->
                    if (!isInputEnabled) disableAmountInputEditText()
                }
            }
        }
    }

    fun clearSelectedAssetDetail() {
        with(binding) {
            chooseAssetButton.show()
            assetDetailGroup.hide()
            assetIconImageView.setImageResource(R.drawable.ic_asset_oval_bg)
            amountEditText.setText("")
            approximateValueTextView.text = ""
            balanceTextView.isVisible = false
        }
    }

    fun setChooseAssetButtonOnClickListener(onClick: () -> Unit) {
        with(binding) {
            assetShortNameContainer.setOnClickListener { onClick() }
            chooseAssetButton.setOnClickListener { onClick() }
        }
    }

    fun setOnTextChangedListener(listener: TextChangeListener) {
        this.textChangeListener = listener
        textChangeWatcher = binding.amountEditText.addTextChangedListener(afterTextChanged = afterTextChangedListener)
    }

    fun setAmountWithoutTriggeringTextChangeListener(amount: String) {
        with(binding.amountEditText) {
            removeTextChangedListener(textChangeWatcher)
            setText(amount)
            setSelection(amount.length)
            if (textChangeWatcher != null) {
                addTextChangedListener(textChangeWatcher)
            }
        }
    }

    fun setApproximateValueText(approximateValue: String) {
        binding.approximateValueTextView.text = approximateValue
    }

    fun setAssetDetails(
        formattedBalance: String,
        assetShortName: AssetName,
        verificationTierConfiguration: VerificationTierConfiguration
    ) {
        setBalanceText(formattedBalance)
        with(binding) {
            assetShortNameTextView.apply {
                text = assetShortName.getName(resources)
                val verificationTierDrawable = verificationTierConfiguration.drawableResId?.let { drawableResId ->
                    AppCompatResources.getDrawable(context, drawableResId)
                }
                setDrawable(end = verificationTierDrawable)
            }
            chooseAssetButton.hide()
            assetDetailGroup.show()
        }
    }

    fun setAssetDetails(
        amount: String,
        assetShortName: AssetName,
        verificationTierConfiguration: VerificationTierConfiguration,
        approximateValue: String
    ) {
        with(binding) {
            assetShortNameTextView.apply {
                text = assetShortName.getName(resources)
                val verificationTierDrawable = verificationTierConfiguration.drawableResId?.let { drawableResId ->
                    AppCompatResources.getDrawable(context, drawableResId)
                }
                setDrawable(end = verificationTierDrawable)
            }
            approximateValueTextView.text = approximateValue
            amountEditText.setText(amount)
            chooseAssetButton.hide()
            assetDetailGroup.show()
        }
    }

    fun setImageDrawable(drawable: Drawable?) {
        binding.assetIconImageView.setImageDrawable(drawable)
    }

    fun setInputFilter(inputFilter: InputFilter) {
        binding.amountEditText.filters = arrayOf(inputFilter)
    }

    private fun setBalanceText(formattedBalance: String) {
        binding.balanceTextView.text = resources.getString(R.string.balance_formatted, formattedBalance)
    }

    // Since there are 2 different SwapAssetInputView in the same layout, amountEditTexts have the same id
    // and this causes system to save & restore view states
    // Generating new id for amountEditText solves the issue
    private fun initViewIdAndConstraints() {
        val newViewId = View.generateViewId()
        binding.amountEditText.id = newViewId
        (binding.approximateValueTextView.layoutParams as? LayoutParams)?.run {
            topToBottom = newViewId
            startToStart = newViewId
            endToEnd = newViewId
        }
    }

    fun interface TextChangeListener {
        fun onTextChanged(text: CharSequence?)
    }

    override fun onSaveInstanceState(): Parcelable {
        return CustomInputSavedState(super.onSaveInstanceState(), latestAmountInputValue)
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        super.onRestoreInstanceState(state)
        (state as? CustomInputSavedState)?.run {
            latestAmountInputValue = text
        }
    }

    private fun disableAmountInputEditText() {
        binding.amountEditText.apply {
            isFocusable = false
            isClickable = false
            isFocusableInTouchMode = false
            keyListener = null
        }
    }

    private fun initRootClickListener() {
        binding.root.setOnClickListener {
            with(binding.amountEditText) {
                if (isVisible && isFocusable) requestFocusAndShowKeyboard()
            }
        }
    }
}
