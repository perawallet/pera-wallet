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

package com.algorand.android.ui.lock

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.customviews.DialPadView
import com.algorand.android.customviews.SixDigitPasswordView
import com.algorand.android.databinding.BottomSheetViewPassphraseLockBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accounts.ViewPassphraseLockViewModel
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BasePasscodeVerificationBottomSheet :
    BaseBottomSheet(R.layout.bottom_sheet_view_passphrase_lock, false) {

    protected open val titleResId: Int? = null

    private var lockHandler: Handler? = null

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
                    if (viewPassphraseLockViewModel.getPassword() == givenPassword) {
                        onPasscodeSuccess()
                    } else {
                        onPasscodeError()
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
        configureToolbar()
        binding.viewPassphraseLockDialPadView.setDialPadListener(dialPadListener)
    }

    private fun configureToolbar() {
        val toolbarConfiguration = ToolbarConfiguration(
            backgroundColor = R.color.primary_background,
            startIconResId = R.drawable.ic_left_arrow,
            titleResId = titleResId,
            startIconClick = ::navBack
        )
        binding.customToolbar.configure(toolbarConfiguration)
    }

    override fun onStart() {
        super.onStart()
        if (viewPassphraseLockViewModel.isNotPasswordChosen()) {
            onPasscodeSuccess()
        }
    }

    override fun onResume() {
        super.onResume()
        if (viewPassphraseLockViewModel.isBiometricActive()) {
            lockHandler = Handler(Looper.myLooper() ?: Looper.getMainLooper())
            lockHandler?.post {
                activity?.showBiometricAuthentication(
                    getString(R.string.app_name),
                    getString(R.string.please_scan_your_fingerprint_or),
                    getString(R.string.cancel),
                    successCallback = { onPasscodeSuccess() }
                )
            }
        }
    }

    override fun onPause() {
        binding.viewPassphraseLockSixDigitPasswordView.cancelAnimations()
        super.onPause()
        lockHandler?.removeCallbacksAndMessages(null)
    }

    protected open fun onPasscodeSuccess() {
        navBack()
    }

    protected open fun onPasscodeError() {
        binding.viewPassphraseLockSixDigitPasswordView.clearWithAnimation()
    }
}
