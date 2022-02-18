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
import com.algorand.android.R
import com.algorand.android.models.BalanceInput
import com.algorand.android.models.CustomInputState
import com.algorand.android.utils.BalanceInputFormatter
import java.math.BigInteger
import kotlin.properties.Delegates

class AlgorandAmountInputTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : AppCompatTextView(context, attrs) {

    var decimalLimit: Int? by Delegates.observable(null) { _, oldValue, newValue ->
        if (oldValue != newValue && newValue != null) {
            algorandAmountFormatter.setOnInputChangeListener(inputChangeListener)
            algorandAmountFormatter.maxDecimalLimit = newValue
            text = algorandAmountFormatter.amountInitialPlaceholder
        }
    }

    private var amountTextColor: Int by Delegates.observable(R.color.tertiaryTextColor) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            setTextColor(ContextCompat.getColor(context, newValue))
        }
    }

    private var listener: Listener? = null

    private val inputChangeListener = BalanceInputFormatter.Listener {
        updateTextColor(it.formattedBalance)
        updateText(it.formattedBalanceString)
        listener?.onBalanceChanged(it)
    }

    private val algorandAmountFormatter = BalanceInputFormatter()

    fun updateBalance(amount: String) {
        algorandAmountFormatter.updateAmount(amount)
    }

    fun setOnBalanceChangeListener(listener: Listener) {
        this.listener = listener
    }

    fun onNumberEntered(number: Int) {
        algorandAmountFormatter.onNumberClick(number)
    }

    fun onDotEntered() {
        algorandAmountFormatter.onDotClick()
    }

    fun onBackspaceEntered() {
        algorandAmountFormatter.onBackspaceClick()
    }

    private fun updateTextColor(amount: BigInteger) {
        amountTextColor = if (amount == BigInteger.ZERO) {
            R.color.tertiaryTextColor
        } else {
            R.color.primaryTextColor
        }
    }

    private fun updateText(amountAsString: String) {
        text = amountAsString
    }

    override fun onSaveInstanceState(): Parcelable {
        return CustomInputState(super.onSaveInstanceState(), text.toString())
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        (state as? CustomInputState)?.run {
            super.onRestoreInstanceState(superState)
            updateBalance(text)
        }
    }

    fun interface Listener {
        fun onBalanceChanged(balanceInput: BalanceInput)
    }
}
