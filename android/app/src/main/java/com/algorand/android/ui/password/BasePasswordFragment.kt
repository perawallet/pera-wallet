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

package com.algorand.android.ui.password

import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.databinding.FragmentBasePasswordBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.preference.savePassword
import com.algorand.android.utils.viewbinding.viewBinding
import javax.inject.Inject
import kotlin.properties.Delegates

abstract class BasePasswordFragment : DaggerBaseFragment(R.layout.fragment_base_password) {

    abstract fun handleNextNavigation()

    abstract val initialTitleResId: Int
    abstract val nextTitleResId: Int

    @Inject
    lateinit var sharedPref: SharedPreferences

    private var chosenPassword by Delegates.observable<String?>(null, { _, _, newValue ->
        binding.passwordView.clear()
        if (newValue != null) {
            binding.headlineTextView.setText(nextTitleResId)
        } else {
            binding.headlineTextView.setText(initialTitleResId)
        }
    })

    private val toolbarConfiguration = ToolbarConfiguration(
        backgroundColor = R.color.primary_background,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackPressed
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentBasePasswordBinding::bind)

    private val dialPadListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            binding.passwordView.onNewDigit(digit = number, onNewDigitAdded = ::onNewDigitAdded)
        }

        override fun onBackspaceClick() {
            binding.passwordView.removeLastDigit()
        }
    }

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            onBackPressed()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        chosenPassword = null
        binding.dialpadView.setDialPadListener(dialPadListener)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    private fun onNewDigitAdded(isNewDigitAdded: Boolean, isPasswordFilled: Boolean) {
        if (!isNewDigitAdded) return
        if (isPasswordFilled) {
            val enteredPassword = binding.passwordView.getPassword()
            if (chosenPassword == null) {
                chosenPassword = enteredPassword
            } else {
                verifyPassword(enteredPassword)
            }
        }
    }

    private fun verifyPassword(enteredPassword: String) {
        if (chosenPassword == enteredPassword) {
            sharedPref.savePassword(enteredPassword)
            handleNextNavigation()
        } else {
            showPasswordDidNotMatchError()
        }
    }

    private fun showPasswordDidNotMatchError() {
        binding.passwordView.clearWithAnimation()
        showGlobalError(
            errorMessage = getString(R.string.pin_does_not),
            title = getString(R.string.wrong_pin)
        )
    }

    private fun onBackPressed() {
        if (chosenPassword != null) {
            chosenPassword = null
            binding.passwordView.clear()
        } else {
            navBack()
        }
    }

    override fun onPause() {
        binding.passwordView.cancelAnimations()
        super.onPause()
    }
}
