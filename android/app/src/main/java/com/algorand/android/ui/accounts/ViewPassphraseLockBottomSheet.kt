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

package com.algorand.android.ui.accounts

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.SixDigitPasswordView
import com.algorand.android.databinding.BottomSheetViewPassphraseLockBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ViewPassphraseLockBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_view_passphrase_lock, false) {

    private var lockHandler: Handler? = null

    private val useBiometric by lazy { viewPassphraseLockViewModel.isBiometricActive() }

    private val currentPassword by lazy { viewPassphraseLockViewModel.getPassword() }

    private val toolbarConfiguration = ToolbarConfiguration(
        backgroundColor = R.color.primaryBackground,
        startIconResId = R.drawable.ic_left_arrow,
        titleResId = R.string.enter_a_passcode,
        startIconClick = ::navBack
    )

    private val args: ViewPassphraseLockBottomSheetArgs by navArgs()

    private val binding by viewBinding(BottomSheetViewPassphraseLockBinding::bind)

    private val viewPassphraseLockViewModel: ViewPassphraseLockViewModel by viewModels()

    private val dialPadListener = object : DialPadView.DialPadListener {
        override fun onNumberClick(number: Int) {
            binding.viewPassphraseLockSixDigitPasswordView.onNewDigit(number, onNewDigitAdded = { isNewDigitAdded ->
                if (!isNewDigitAdded) {
                    return@onNewDigit
                }
                val passwordSize = binding.viewPassphraseLockSixDigitPasswordView.getPasswordSize()
                if (passwordSize == SixDigitPasswordView.PASSWORD_LENGTH) {
                    val givenPassword = binding.viewPassphraseLockSixDigitPasswordView.getPassword()
                    if (currentPassword == givenPassword) {
                        navigateBackAndShowPassphrase()
                    } else {
                        binding.viewPassphraseLockSixDigitPasswordView.clearWithAnimation()
                        context?.showAlertDialog(
                            getString(R.string.wrong_password),
                            getString(R.string.you_should_enter_your_correct_password)
                        )
                    }
                }
            })
        }

        override fun onBackspaceClick() {
            binding.viewPassphraseLockSixDigitPasswordView.removeLastDigit()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.customToolbar.configure(toolbarConfiguration)
        binding.viewPassphraseLockDialPadView.setDialPadListener(dialPadListener)
    }

    override fun onStart() {
        super.onStart()
        if (viewPassphraseLockViewModel.isNotPasswordChosen()) {
            navigateBackAndShowPassphrase()
        }
    }

    override fun onResume() {
        super.onResume()
        if (useBiometric) {
            lockHandler = Handler(Looper.myLooper() ?: Looper.getMainLooper())
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
        binding.viewPassphraseLockSixDigitPasswordView.cancelAnimations()
        super.onPause()
        lockHandler?.removeCallbacksAndMessages(null)
    }

    private fun navigateBackAndShowPassphrase() {
        setNavigationResult(VIEW_PASSPHRASE_ADDRESS_KEY, args.publicKey)
        navBack()
    }

    companion object {
        const val VIEW_PASSPHRASE_ADDRESS_KEY = "view_passphrase_address_key"
    }
}
