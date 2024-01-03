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
import android.util.AttributeSet
import android.view.inputmethod.EditorInfo.IME_ACTION_DONE
import android.view.inputmethod.EditorInfo.IME_ACTION_NEXT
import androidx.core.view.children
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputConfiguration
import com.google.android.flexbox.AlignContent
import com.google.android.flexbox.AlignItems
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout

class PassphraseInputGroup @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FlexboxLayout(context, attrs) {

    private var listener: Listener? = null

    private val passphraseInputListener = object : PassphraseInput.Listener {
        override fun onFocusedWordChanged(itemOrder: Int, inputText: String) {
            listener?.onFocusedWordChanged(itemOrder, inputText)
        }

        override fun onClipboardTextPasted(clipboardText: String) {
            listener?.onClipboardTextPasted(clipboardText)
        }

        override fun onViewFocused(itemOrder: Int, yCoordinate: Int) {
            listener?.onInputFocus(itemOrder, yCoordinate)
        }

        override fun onImeActionClicked(itemOrder: Int, actionId: Int) {
            when (actionId) {
                IME_ACTION_NEXT -> listener?.onNextClick(itemOrder)
                IME_ACTION_DONE -> listener?.onDoneClick(itemOrder)
            }
        }
    }

    private val passphraseInputLayoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
        flexBasisPercent = PASSPHRASE_INPUT_FLEX_BASIS_PERCENT
    }

    init {
        flexWrap = FlexWrap.WRAP
        flexDirection = FlexDirection.ROW
        alignContent = AlignContent.STRETCH
        alignItems = AlignItems.STRETCH
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun safeFocusNextItem(itemOrder: Int) {
        if (itemOrder < childCount - 1) {
            getInputViewByOrder(itemOrder.inc())?.focusToInput()
            return
        }
        listener?.onDoneClick(itemOrder)
    }

    fun focusNextItem() {
        val (_, itemOrder) = getIndexOfFocusedChild()
        safeFocusNextItem(itemOrder)
    }

    fun updatePassphraseInputsConfiguration(passphraseInputConfiguration: PassphraseInputConfiguration) {
        val focusedInputView = getInputViewByOrder(passphraseInputConfiguration.order)
        focusedInputView?.setConfiguration(passphraseInputConfiguration)
    }

    fun updatePassphraseInputsConfiguration(passphraseInputConfigurationList: List<PassphraseInputConfiguration>) {
        passphraseInputConfigurationList.forEach { passphraseInputConfiguration ->
            val passphraseInput = getInputViewByOrder(passphraseInputConfiguration.order)
            passphraseInput?.setConfiguration(passphraseInputConfiguration)
        }
        clearFocusedInputFocus()
    }

    fun initPassphraseInputGroup(passphraseInputConfigurationList: List<PassphraseInputConfiguration>?) {
        removeAllViews()
        passphraseInputConfigurationList?.forEach { passphraseInputConfiguration ->
            val passphraseInput = createPassphraseInput(passphraseInputConfiguration)
            val layoutParams = passphraseInputLayoutParams.apply { order = passphraseInputConfiguration.order }
            addView(passphraseInput, layoutParams)
        }
    }

    private fun createPassphraseInput(passphraseInputConfiguration: PassphraseInputConfiguration): PassphraseInput {
        return PassphraseInput(context).apply {
            setConfiguration(passphraseInputConfiguration = passphraseInputConfiguration)
            setListener(listener = passphraseInputListener)
            initPassphraseInput(imeOption = passphraseInputConfiguration.imeOptions)
            initPassphraseIndexView(
                index = passphraseInputConfiguration.index,
                itemOrder = passphraseInputConfiguration.order
            )
        }
    }

    private fun getInputViewByOrder(itemOrder: Int): PassphraseInput? {
        return children.firstOrNull { it is PassphraseInput && it.order == itemOrder } as? PassphraseInput
    }

    private fun getIndexOfFocusedChild(): Pair<Int, Int> {
        val focusedInput = getFocusedInputView()
        val itemOrder = focusedInput?.order ?: 0
        val itemIndex = focusedInput?.index ?: 0
        return itemIndex to itemOrder
    }

    private fun getFocusedInputView(): PassphraseInput? {
        return focusedChild as? PassphraseInput
    }

    private fun clearFocusedInputFocus() {
        getFocusedInputView()?.clearFocus()
    }

    interface Listener {
        fun onInputFocus(itemOrder: Int, yCoordinate: Int)
        fun onFocusedWordChanged(itemOrder: Int, word: String)
        fun onDoneClick(itemOrder: Int)
        fun onNextClick(itemOrder: Int)
        fun onClipboardTextPasted(clipboardData: String)
    }

    companion object {
        private const val PASSPHRASE_INPUT_FLEX_BASIS_PERCENT = 0.5F
    }
}
