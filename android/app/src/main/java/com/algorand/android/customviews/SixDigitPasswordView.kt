/*
 * Copyright 2019 Algorand, Inc.
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
import android.util.AttributeSet
import android.widget.ImageButton
import android.widget.LinearLayout
import com.algorand.android.R
import com.algorand.android.databinding.CustomSixDigitPasswordBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SixDigitPasswordView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomSixDigitPasswordBinding::inflate)

    private lateinit var digitViewList: MutableList<ImageButton>
    private var password: MutableList<Int> = mutableListOf()

    init {
        orientation = HORIZONTAL
        initViewList()
    }

    private fun initViewList() {
        with(binding) {
            digitViewList = mutableListOf(
                digit1,
                digit2,
                digit3,
                digit4,
                digit5,
                digit6
            )
        }
    }

    fun onNewDigit(digit: Int): Boolean {
        if (password.size < PASSWORD_LENGTH) {
            digitViewList[password.size].setImageResource(R.drawable.filled_password_digit)
            digitViewList[password.size].isPressed = true // this is for ripple effect
            digitViewList[password.size].isPressed = false
            password.add(digit)
            return true
        } else {
            return false
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
        digitViewList.forEach { digitImageView ->
            digitImageView.setImageResource(R.drawable.unfilled_password_digit)
        }
    }

    companion object {
        const val PASSWORD_LENGTH = 6
    }
}
