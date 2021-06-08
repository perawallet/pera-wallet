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

package com.algorand.android.ui.accounts

import android.content.SharedPreferences
import android.os.Bundle
import android.os.Handler
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.SixDigitPasswordView
import com.algorand.android.databinding.FragmentViewPassphraseLockBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.preference.getPassword
import com.algorand.android.utils.preference.isBiometricActive
import com.algorand.android.utils.preference.isPasswordChosen
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class ViewPassphraseLockFragment : DaggerBaseFragment(R.layout.fragment_view_passphrase_lock) {

    private var lockHandler: Handler? = null

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val useBiometric by lazy { sharedPref.isBiometricActive() }

    private val currentPassword by lazy { sharedPref.getPassword() }

    private val toolbarConfiguration = ToolbarConfiguration(
        backgroundColor = R.color.tertiaryBackground,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    private val args: ViewPassphraseLockFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentViewPassphraseLockBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    override val fragmentConfiguration =
        FragmentConfiguration(
            toolbarConfiguration = toolbarConfiguration,
            statusBarConfiguration = statusBarConfiguration
        )

    override fun onStart() {
        super.onStart()
        if (sharedPref.isPasswordChosen().not()) {
            navigateBackAndShowPassphrase()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.viewPassphraseLockDialPadView.setDialPadListener(dialPadListener)
    }

    override fun onResume() {
        super.onResume()
        if (useBiometric) {
            lockHandler = Handler()
            lockHandler?.post {
                activity?.showBiometricAuthentication(
                    getString(R.string.app_name),
                    getString(R.string.please_scan_your_fingerprint_or),
                    getString(R.string.cancel),
                    successCallback = { navigateBackAndShowPassphrase() }
                )
            }
        }
    }

    override fun onPause() {
        super.onPause()
        lockHandler?.removeCallbacksAndMessages(null)
    }

    private fun navigateBackAndShowPassphrase() {
        setNavigationResult(VIEW_PASSPHRASE_ADDRESS_KEY, args.publicKey)
        navBack()
    }

    private val dialPadListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            val isNewDigitAdded = binding.viewPassphraseLockSixDigitPasswordView.onNewDigit(number)
            if (!isNewDigitAdded) {
                return
            }
            val passwordSize = binding.viewPassphraseLockSixDigitPasswordView.getPasswordSize()
            if (passwordSize == SixDigitPasswordView.PASSWORD_LENGTH) {
                val givenPassword = binding.viewPassphraseLockSixDigitPasswordView.getPassword()
                if (currentPassword == givenPassword) {
                    navigateBackAndShowPassphrase()
                } else {
                    binding.viewPassphraseLockSixDigitPasswordView.clear()
                    context?.showAlertDialog(
                        getString(R.string.wrong_password),
                        getString(R.string.you_should_enter_your_correct_password)
                    )
                }
            }
        }

        override fun onBackspaceClick() {
            binding.viewPassphraseLockSixDigitPasswordView.removeLastDigit()
        }
    }

    companion object {
        const val VIEW_PASSPHRASE_ADDRESS_KEY = "view_passphrase_address_key"
    }
}
