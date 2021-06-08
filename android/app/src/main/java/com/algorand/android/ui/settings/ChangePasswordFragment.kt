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

package com.algorand.android.ui.settings

import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.SixDigitPasswordView
import com.algorand.android.databinding.FragmentChangePasswordBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.preference.savePassword
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlin.properties.Delegates

@AndroidEntryPoint
class ChangePasswordFragment : DaggerBaseFragment(R.layout.fragment_change_password) {

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val binding by viewBinding(FragmentChangePasswordBinding::bind)

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
        startIconResId = R.drawable.ic_close,
        startIconClick = ::onBackPressed
    )

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    override val fragmentConfiguration =
        FragmentConfiguration(
            toolbarConfiguration = toolbarConfiguration,
            statusBarConfiguration = statusBarConfiguration
        )

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
            navBack()
        } else {
            // Wrong password entered.
            showPasswordDidNotMatchError()
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
