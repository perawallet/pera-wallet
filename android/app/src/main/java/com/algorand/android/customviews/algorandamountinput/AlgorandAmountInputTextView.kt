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

package com.algorand.android.customviews.algorandamountinput

import android.content.Context
import android.os.Parcelable
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.core.view.doOnLayout
import com.algorand.android.R
import com.algorand.android.models.AmountInput
import com.algorand.android.models.CustomInputSavedState
import com.algorand.android.utils.AmountInputFormatter
import kotlin.properties.Delegates

class AlgorandAmountInputTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : AppCompatTextView(context, attrs) {

    private var amountTextColor: Int by Delegates.observable(R.color.tertiary_text_color) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            setTextColor(ContextCompat.getColor(context, newValue))
        }
    }

    private var listener: Listener? = null

    private val inputChangeListener = AmountInputFormatter.Listener {
        listener?.onAmountChanged(it)
        text = it.formattedAmount
        updateTextColor(it.isAmountValid)
    }

    private val algorandAmountFormatter = AmountInputFormatter()

    init {
        algorandAmountFormatter.setOnInputChangeListener(inputChangeListener)
    }

    fun setOnBalanceChangeListener(listener: Listener) {
        this.listener = listener
    }

    fun setFractionDecimalLimit(setFractionDecimals: Int) {
        doOnLayout {
            with(algorandAmountFormatter) {
                fractionDecimalLimit = setFractionDecimals
                hint = amountInitialPlaceholder
            }
        }
    }

    fun setAmount(amount: String) {
        algorandAmountFormatter.setAmount(amount)
    }

    fun onNumberEntered(number: Int) {
        algorandAmountFormatter.onNumberClick(number)
    }

    fun onDecimalSeparatorClicked() {
        algorandAmountFormatter.onDecimalSeparatorClick()
    }

    fun onBackspaceEntered() {
        algorandAmountFormatter.onBackspaceClick()
    }

    private fun updateTextColor(isAmountValid: Boolean) {
        amountTextColor = if (isAmountValid) R.color.primary_text_color else R.color.tertiary_text_color
    }

    override fun onSaveInstanceState(): Parcelable {
        return CustomInputSavedState(super.onSaveInstanceState(), text.toString())
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        super.onRestoreInstanceState(state)
        (state as? CustomInputSavedState)?.run {
            setAmount(text)
        }
    }

    fun interface Listener {
        fun onAmountChanged(amountInput: AmountInput)
    }
}
