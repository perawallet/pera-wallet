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

package com.algorand.android.ui.lockpreference

import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.SixDigitPasswordView
import com.algorand.android.databinding.FragmentChoosePasswordBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.lockpreference.ChoosePasswordFragmentDirections.Companion.actionChoosePasswordFragmentToBiometricRegistrationFragment
import com.algorand.android.ui.lockpreference.ChoosePasswordFragmentDirections.Companion.actionPopLockPreferenceNavigation
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.isBiometricAvailable
import com.algorand.android.utils.preference.savePassword
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlin.properties.Delegates

@AndroidEntryPoint
class ChoosePasswordFragment : DaggerBaseFragment(R.layout.fragment_choose_password) {

    @Inject
    lateinit var sharedPref: SharedPreferences

    private var chosenPassword by Delegates.observable<String?>(null, { _, _, newValue ->
        binding.passwordView.clear()
        if (newValue != null) {
            binding.headlineTextView.setText(R.string.enter_the_same_six_digits)
            getAppToolbar()?.changeTitle(getString(R.string.verify_passcode))
        } else {
            binding.headlineTextView.setText(R.string.choose_a_six_digit)
            getAppToolbar()?.changeTitle(getString(R.string.choose_passcode))
        }
    })

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.choose_passcode,
        backgroundColor = R.color.tertiaryBackground,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::onBackPressed
    )

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    override val fragmentConfiguration =
        FragmentConfiguration(
            toolbarConfiguration = toolbarConfiguration,
            statusBarConfiguration = statusBarConfiguration
        )

    private val binding by viewBinding(FragmentChoosePasswordBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        chosenPassword = null
        binding.dialpadView.setDialPadListener(dialPadListener)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                onBackPressed()
            }
        })
    }

    private val dialPadListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            val isNewDigitAdded = binding.passwordView.onNewDigit(number)
            if (!isNewDigitAdded) {
                return
            }
            if (binding.passwordView.getPasswordSize() == SixDigitPasswordView.PASSWORD_LENGTH) {
                val enteredPassword = binding.passwordView.getPassword()
                if (chosenPassword == null) {
                    chosenPassword = enteredPassword
                } else {
                    verifyPassword(enteredPassword)
                }
            }
        }

        override fun onBackspaceClick() {
            binding.passwordView.removeLastDigit()
        }
    }

    private fun verifyPassword(enteredPassword: String) {
        if (chosenPassword == enteredPassword) {
            // Password Verified
            sharedPref.savePassword(enteredPassword)
            handleNextNavigation()
        } else {
            // Wrong password entered.
            showPasswordDidNotMatchError()
        }
    }

    private fun handleNextNavigation() {
        if (context?.isBiometricAvailable() == true) {
            nav(actionChoosePasswordFragmentToBiometricRegistrationFragment())
        } else {
            nav(actionPopLockPreferenceNavigation())
        }
    }

    private fun showPasswordDidNotMatchError() {
        binding.passwordView.clear()
        context?.alertDialog {
            setTitle(getString(R.string.wrong_password))
            setMessage(getString(R.string.password_did_not_match_with_previous_password))
            setPositiveButton(R.string.yes) { dialog, _ -> dialog.dismiss() }
        }?.show()
    }

    private fun onBackPressed() {
        if (chosenPassword != null) {
            chosenPassword = null
            binding.passwordView.clear()
        } else {
            navBack()
        }
    }
}
