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
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.animation.ValueAnimator
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

    private val digitViewList = mutableListOf<ImageButton>()
    private val password = mutableListOf<Int>()
    private val pinAnimators = mutableListOf<Animator>()

    // TODO: 11.02.2022 Move animation into xml files
    private val wrongPinAnimator by lazy {
        ObjectAnimator.ofPropertyValuesHolder(
            this@SixDigitPasswordView,
            PropertyValuesHolder.ofFloat("translationX", WRONG_PIN_ANIMATION_RATE),
            PropertyValuesHolder.ofFloat("translationX", -WRONG_PIN_ANIMATION_RATE)
        ).apply {
            duration = WRONG_PIN_ANIMATION_DURATION
            repeatMode = ValueAnimator.REVERSE
            repeatCount = WRONG_PIN_ANIMATION_REPEAT_COUNT
            doOnCancel { it.end() }
        }
    }

    private val isWrongPinAnimatorRunning: Boolean
        get() = wrongPinAnimator.isRunning

    init {
        orientation = HORIZONTAL
        initViewList()
    }

    private fun initViewList() {
        with(binding) { digitViewList.addAll(listOf(digit1, digit2, digit3, digit4, digit5, digit6)) }
    }

    fun onNewDigit(digit: Int, onNewDigitAdded: (Boolean) -> Unit) {
        if (isWrongPinAnimatorRunning) {
            onNewDigitAdded.invoke(false)
            return
        }
        if (password.size < PASSWORD_LENGTH) {
            val enteredPin = digitViewList[password.size]
            password.add(digit)
            enteredPin.setImageResource(R.drawable.filled_password_digit)
            animateEnteringPin(enteredPin) { onNewDigitAdded.invoke(true) }
        } else {
            onNewDigitAdded.invoke(false)
        }
    }

    fun getPasswordSize(): Int {
        return password.size
    }

    fun removeLastDigit() {
        if (password.size > 0) {
            password.removeAt(password.size - 1)
            digitViewList[password.size].setImageResource(R.drawable.unfilled_password_digit)
        }
    }

    fun getPassword(): String {
        return password.toString()
    }

    fun clear() {
        password.clear()
        digitViewList.forEach { it.setImageResource(R.drawable.unfilled_password_digit) }
    }

    fun clearWithAnimation() {
        digitViewList.forEach { it.setImageResource(R.drawable.filled_wrong_password_digit) }
        animateWrongPin(onAnimationFinish = { clear() })
    }

    fun cancelAnimations() {
        pinAnimators.forEach { it.cancel() }
        wrongPinAnimator.cancel()
        pinAnimators.clear()
    }

    private fun animateEnteringPin(pin: View, onAnimationFinish: () -> Unit) {
        // TODO: 11.02.2022 Move animation into xml files
        ObjectAnimator.ofPropertyValuesHolder(
            pin,
            PropertyValuesHolder.ofFloat("scaleX", ENTERING_PIN_ANIMATION_RATE),
            PropertyValuesHolder.ofFloat("scaleY", ENTERING_PIN_ANIMATION_RATE)
        ).apply {
            duration = ENTERING_PIN_ANIMATION_DURATION
            repeatMode = ValueAnimator.REVERSE
            repeatCount = 1
            doOnStart { pinAnimators.add(it) }
            doOnCancel { it.end() }
            doOnEnd {
                pinAnimators.remove(it)
                onAnimationFinish.invoke()
            }
        }.start()
    }

    private fun animateWrongPin(onAnimationFinish: () -> Unit) {
        if (isWrongPinAnimatorRunning) return
        wrongPinAnimator.apply {
            doOnEnd { onAnimationFinish.invoke() }
        }.start()
    }

    companion object {
        const val PASSWORD_LENGTH = 6
        private const val WRONG_PIN_ANIMATION_RATE = 100f
        private const val WRONG_PIN_ANIMATION_DURATION = 100L
        private const val WRONG_PIN_ANIMATION_REPEAT_COUNT = 3

        private const val ENTERING_PIN_ANIMATION_RATE = 1.5f
        private const val ENTERING_PIN_ANIMATION_DURATION = 100L
    }
}
