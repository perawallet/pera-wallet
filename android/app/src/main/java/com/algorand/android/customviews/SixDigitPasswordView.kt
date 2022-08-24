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

import android.animation.Animator
import android.animation.AnimatorInflater
import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.ImageButton
import android.widget.LinearLayout
import androidx.core.animation.doOnCancel
import androidx.core.animation.doOnEnd
import androidx.core.animation.doOnStart
import com.algorand.android.R
import com.algorand.android.databinding.CustomSixDigitPasswordBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SixDigitPasswordView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomSixDigitPasswordBinding::inflate)

    private var listener: Listener? = null

    private val digitViewList = mutableListOf<ImageButton>()
    private val password = mutableListOf<Int>()
    private val pinAnimators = mutableListOf<Animator>()

    private val wrongPinAnimator by lazy {
        AnimatorInflater.loadAnimator(context, R.animator.wrong_pin_animator).apply {
            setTarget(this@SixDigitPasswordView)
            doOnCancel { it.end() }
        }
    }

    private val isWrongPinAnimatorRunning: Boolean
        get() = wrongPinAnimator.isRunning

    init {
        orientation = HORIZONTAL
        initViewList()
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun onNewDigit(digit: Int) {
        if (isWrongPinAnimatorRunning) return
        password.add(digit)
        listener?.onNewPinAdded()
        when {
            password.size < PASSWORD_LENGTH -> digitViewList[password.size - 1].run {
                setImageResource(R.drawable.filled_password_digit)
                animateEnteringPin(this)
            }
            isPasswordFilled() -> listener?.onPinCodeCompleted(password.toString())
        }
    }

    fun removeLastDigit() {
        if (password.size > 0) {
            password.removeLast()
            digitViewList[password.size].setImageResource(R.drawable.unfilled_password_digit)
        }
    }

    fun clear() {
        password.clear()
        pinAnimators.clear()
        digitViewList.forEach { it.setImageResource(R.drawable.unfilled_password_digit) }
    }

    fun clearWithAnimation() {
        clearPassword()
        digitViewList.forEach { it.setImageResource(R.drawable.filled_wrong_password_digit) }
        animateWrongPin()
    }

    fun cancelAnimations() {
        pinAnimators.forEach { it.cancel() }
        wrongPinAnimator.cancel()
        pinAnimators.clear()
    }

    private fun initViewList() {
        with(binding) { digitViewList.addAll(listOf(digit1, digit2, digit3, digit4, digit5, digit6)) }
    }

    private fun animateEnteringPin(pin: View) {
        AnimatorInflater.loadAnimator(pin.context, R.animator.enter_pin_animator).apply {
            setTarget(pin)
            doOnStart { pinAnimators.add(it) }
            doOnCancel { it.end() }
        }.start()
    }

    private fun animateWrongPin() {
        if (isWrongPinAnimatorRunning) return
        wrongPinAnimator.apply { doOnEnd { clearUi() } }.start()
    }

    private fun isPasswordFilled(): Boolean = password.size == PASSWORD_LENGTH

    private fun clearPassword() {
        password.clear()
    }

    private fun clearUi() {
        pinAnimators.clear()
        digitViewList.forEach { it.setImageResource(R.drawable.unfilled_password_digit) }
    }

    interface Listener {
        fun onNewPinAdded() {}
        fun onPinCodeCompleted(pinCode: String)
    }

    companion object {
        private const val PASSWORD_LENGTH = 6
    }
}
